# Emailer interface for generating and sending
# emails to users
#
class UserMailer < ActionMailer::Base
  layout 'email', :except => :feedback_offer
  helper :application, :emails

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

  # Invite email for non facebook invites 
  #
  def new_invite(invite)
    @invite       = invite
    @sender       = invite.user
    @action       = "Join me on #{CONFIG[:name]}"
    @source       = "email_invite"

    admin         = User.first

    generate_attributes(admin,@sender.id,invite,EmailPurpose::Invite)

    recipients    invite.recipient_id 
    from          EMAILS[:contact]
    subject       @action
  end

  # Suggestions for a new user to add more purchases.
  #
  def after_join_suggestions(user,suggestions,suggestions_done_ids)
    @user = user
    @suggestion = nil


    suggestions.each do |suggestion|
      unless suggestions_done_ids.include? suggestion.id
        @suggestion = suggestion
        break
      end
    end

    @action = "Add your first #{@suggestion.thing} on mine"
    @source = "email_suggestions"

    generate_attributes(@user,0,@user,EmailPurpose::Suggestions)

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end

  # Alert the owner whenever someone likes his/her purchase
  #
  def new_like(like)
    @purchase     = like.purchase
    @actor        = like.user 
    @user         = @purchase.user 
    @source       = "email_like"

    @action       = "just liked your #{@purchase.title}"

    generate_attributes(@user,@actor.id,like,EmailPurpose::NewLike)

    recipients    @user.email
    from          EMAILS[:contact]
    subject       "#{@actor.first_name} #{@action}"
  end 

  # Alert user when a new comment is added on a 
  # thread to which the user belongs
  #
  def new_comment(comment,user)
    @owner        = comment.purchase.user
    @comment      = comment
    @actor        = comment.user
    @purchase     = comment.purchase
    @user         = user
    @action       = ""
    @source       = "email_comment"

    if @owner.id == @user.id
      @action    << " commented on your "
    elsif @owner.id == @comment.user.id 
      @action    << " also commented on #{@owner.is_male? ? 'his' : 'her'} "
    else
      @action    << " also commented on #{@owner.first_name}'s "
    end

    @action     << comment.purchase.title 

    generate_attributes(@user,@comment.user.id,@comment,EmailPurpose::NewComment)

    recipients    @user.email
    from          EMAILS[:contact]
    subject       "#{@comment.user.first_name} #{@action}"
  end

  # Alert user when someone starts following him/her
  #
      
  def new_follower(following) 
    @follower     = following.follower 
    @user         = following.user
    @source       = "email_follower"
       
    @action       = "#{@user.first_name}, you have a new follower!"
       
    generate_attributes(@user,@follower.id,following,EmailPurpose::NewFollower)
       
       
    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end 
  
  def run_importer(user)
    @user         = user
    @action       = "Welcome to #{CONFIG[:name]}"
    @source       = "email_run_importer"
		
    generate_attributes(@user,0,@user,EmailPurpose::Importer)

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end

  # Friend activity digest for the user 
  #
  def friend_activity_digest(user,friends,new_friends,purchases)
    @user      = user
    @friends   = friends
    @new_friends = new_friends
    @all_friends = (@friends + @new_friends).uniq
    @purchases = purchases
    @action    = "View what " 

    if @friends.length == 1
      @action << @friends[0].first_name
    else
      @action << "#{@friends[0..-2].map(&:first_name).join(", ")} and "\
                 "#{@friends[-1].first_name}" 
    end

    @action << " bought this week"
    @source = "email_friend_digest"

    generate_attributes(@user,0,@user,EmailPurpose::FriendDigest)

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end

  # Reminder to add a new purchase.
  #
  def add_purchase_reminder(user)
    @user = user

    @source = "email_purchase_reminder"

    generate_attributes(@user,0,@user,EmailPurpose::AddPurchase)

    recipients    @user.email
    from          EMAILS[:contact]
    subject       "Bought anything new this week?"
  end

  # Offer to give feedback on the app customized
  # based on the progress they've made.
  #
  def feedback_offer(user)
    @user = user

    @source = "email_feedback_offer"

    generate_attributes(@user,0,@user,EmailPurpose::FeedbackOffer)

    recipients    @user.email
    from          EMAILS[:natalia]
    subject       "Hello from Natalia at Mine! $5 Amazon Gift Card for your feedback."
  end

  # Send newsletter to all users.
  #
  def news(user)
    @user         = user
    @action       = "Announcing the #{CONFIG[:name]} iPhone app. It's free!"
    @source       = "email_iphone_app"

    generate_attributes(@user,0,@user,EmailPurpose::News)

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

      if (RAILS_ENV == 'production' || @@is_admin) && 
        mail.to.present? && 
        mail.to.first.scan('@').present?

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

  rescue AWS::SES::ResponseError => ex
    user = User.find @@attributes[:recipient_id]
    user.setting.unsubscribe if user && ex.message.match("blacklisted")
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
