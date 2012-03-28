# Emailer interface for generating and sending
# emails to users
#
class UserMailer < ActionMailer::Base
  layout 'email'

  # Welcome email for the user on sign up
  #
  def new_user(user)
    @user         = user
    @action       = "Welcome to #{CONFIG[:name]}!"
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

    @action       = @follower.first_name + " " + @follower.last_name + 
                    " thinks you influence each other's style!"

    generate_attributes(@user,@follower.id,following,EmailPurpose::NewFollower)

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end

  # Alert user whenever he/she is featured as a 
  # top shopper for a particular store
  #
  def top_shopper(user,store)
    @user         = user
    @store        = store
    @action       = "You are now featured as a Top Shopper at #{@store.name}!" 
    @source       = "email_tshopper"

    generate_attributes(@user,0,@store,EmailPurpose::TopShopper)

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end

  # Alert the user to add new products to their closet 
  #
  def create_another_product(user)
    @user         = user
    @action       = "Bought something new this week?"
    @source       = "email_another_product"

    generate_attributes(@user,0,@user,EmailPurpose::AnotherProduct)

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

  # Alert the user to start inviting friends 
  #
  def add_a_friend(user)
    @user         = user
    @action       = "Which of your friends has great style?"
    @source       = "email_add_friend"

    generate_attributes(@user,0,@user,EmailPurpose::AddFriend)

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end

  # Alert the user to start adding stores 
  #
  def add_a_store(user)
    @user         = user
    @action       = "Where do you like to shop?"
    @source       = "email_add_store"

    generate_attributes(@user,0,@user,EmailPurpose::AddStore)

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end

  # Friend activity digest for the user 
  #
  def friend_activity_digest(user,friends,owns,wants)
    @user         = user
    @friends      = friends
    @owns         = owns
    @wants        = wants
    @action       = "What " 

    if @friends.length == 1
      @action         += @friends[0].first_name
    else
      @action         += "#{@friends[0..-2].map(&:first_name).join(", ")} and "\
                         "#{@friends[-1].first_name}" 
    end

    @action       += " added today"
    @source       = "email_friend_digest"

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
    subject       @user_deleted.first_name + ", is deleted from OnCloset"
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
