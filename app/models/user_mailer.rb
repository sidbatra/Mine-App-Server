# Emailer interface for generating and sending
# emails to users
#
class UserMailer < ActionMailer::Base
  layout 'email'
  helper :application

  # Welcome email for the user on sign up
  #
  def new_user(user)
    @user         = user
    @action       = "Welcome to #{CONFIG[:name]}"
    @source       = "email_welcome"

    generate_attributes(@user,0,@user,EmailPurpose::Welcome)

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end

  # Alert user when someone starts following him/her
  #
  def new_follower(following) 
    @follower     = following.follower 
    @user         = following.user
    @source       = "email_follower"

    @action       = "View #{@follower.first_name}'s Mine"

    generate_attributes(@user,@follower.id,following,EmailPurpose::NewFollower)

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end

  # Alert the user to add new purchases 
  #
  def create_another_purchase(user)
    @user         = user
    @action       = "Bought something new this week?"
    @source       = "email_another_purchase"

    generate_attributes(@user,0,@user,EmailPurpose::AnotherPurchase)

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end
  
  # Alert the user to start adding items 
  #
  def add_an_item(user)
    @user         = user
    @action       = "Are you wearing your favorite shoes?"
    @source       = "email_add_item"

    generate_attributes(@user,0,@user,EmailPurpose::AddItem)

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end

  # Friend activity digest for the user 
  #
  def friend_activity_digest(user,friends,purchases)
    @user      = user
    @friends   = friends
    @purchases = purchases
    @action    = "View what " 

    if @friends.length == 1
      @action += @friends[0].first_name
    else
      @action += "#{@friends[0..-2].map(&:first_name).join(", ")} and "\
                 "#{@friends[-1].first_name}" 
    end

    @action += " bought this week"
    @source = "email_friend_digest"

    generate_attributes(@user,0,@user,EmailPurpose::FriendDigest)

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end

  # Safety check email whenever a user is deleted
  #
  def user_deleted(admin,user)
    @user_deleted = user
    @user = admin

    generate_attributes(@user,0,@user,EmailPurpose::Admin)

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @user_deleted.first_name + ", is deleted"
  end

  # Extend the method_missing method to enable email
  # delivery only in production environment
  #
  def self.method_missing(method,*args)

    if method.to_s.match(/^deliver_(.*)/)
      mail = self.send("create_#{$1}".to_sym,*args) 

      if (RAILS_ENV == 'production' || @@is_admin) && mail.to.present?

        response    = @@custom_amazon_ses_mailer.send_raw_email(mail)
        xml         = XmlSimple.xml_in(response.to_s)

        message_id  = xml['SendRawEmailResult'][0]['MessageId'][0]
        request_id  = xml['ResponseMetadata'][0]['RequestId'][0]

        Email.add(@@attributes,message_id,request_id)
      else
        ActiveRecord::Base.logger.info "Preview of email generated \n\n" + 
                                        mail.to_s 
      end

    elsif method.to_s.match(/^preview_(.*)/)
      mail = self.send("create_#{$1}".to_sym,*args) 
      "<b>" + mail.subject + "</b>" + "<br><br>" + mail.body
    else
      super
    end
  end


  protected 

  # Generate email attributes to store in the database
  #
  def generate_attributes(user,sender_id,source,purpose)
    @@is_admin = user.is_admin
    @@attributes = {
                  :recipient_id   => user.id,
                  :sender_id      => sender_id,
                  :emailable_id   => source.id,
                  :emailable_type => source.class.name,
                  :purpose        => purpose}
  end

end
