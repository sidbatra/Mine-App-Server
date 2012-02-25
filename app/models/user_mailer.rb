# Emailer interface for generating and sending
# emails to users
#
class UserMailer < ActionMailer::Base
  layout 'email'

  # Welcome email for the user on sign up
  #
  def new_user(user)
    @user         = user
    @action       = "Welcome"

    generate_attributes(@user.id,0,@user,EmailPurpose::Welcome)

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end

  # Alert user when a new comment is added on a 
  # thread to which the user belongs
  #
  def new_comment(comment,user)
    @owner        = comment.commentable.user
    @comment      = comment
    @user         = user
    @action       = @comment.user.first_name + " " + @comment.user.last_name

    if @owner.id == @user.id
      @action    += " commented on your "
    elsif @owner.id == @comment.user.id 
      @action    += " also commented on #{@owner.is_male? ? 'his' : 'her'} "
    else
      @action    += " also commented on #{@owner.first_name} "\
                    " #{@owner.last_name}'s "
    end

    if(comment.commentable_type == 'Product')
      @action     += comment.commentable.title
    elsif(comment.commentable_type == 'Collection')
      @action     +=  'set'
    end

    generate_attributes(@user.id,@comment.user.id,@comment,EmailPurpose::NewComment)

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action #+ " " + rand(10000).to_s
  end

  # Alert user when someone starts following him/her
  #
  def new_follower(following) 
    @follower     = following.follower 
    @user         = following.user

    @action       = @follower.first_name + " " + @follower.last_name + 
                    " is now following your Closet!"

    generate_attributes(@user.id,@follower.id,following,EmailPurpose::NewFollower)

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

    generate_attributes(@user.id,0,@store,EmailPurpose::TopShopper)

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end

  # Alert user whenever a friend creates a collection 
  #
  def friend_collection(user,collection)
    @owner        = collection.user
    @user         = user
    @collection   = collection 
    @action       = "#{@owner.first_name} just added a collection"

    generate_attributes(@user.id,@collection.user_id,@collection,EmailPurpose::FriendCollection)

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end


  # Alert the owner whenever an action is taken 
  # on his/her product or collection
  #
  def new_action(action)
    action_map    = {'like' => 'likes',
                     'own'  => 'also owns',
                     'want' => 'just added'}

    @actionable   = action.actionable
    @user         = @actionable.user 
    @actor        = action.user 
    @action_name  = action.name

    @action       = "#{@actor.first_name} #{@actor.last_name} " + 
    								"#{action_map[@action_name]} your "

    if(@actionable.class.name == 'Product')
      @action     +=  @actionable.title
    elsif(@actionable.class.name == 'Collection')
      @action     +=  'set'
    end
    
    if @action_name == 'want'
    	@action			+= " to #{@actor.is_male? ? 'his' : 'her'} wishlist!"
    else
    	@action			+= "!"
    end

    generate_attributes(@user.id,@actor.id,action,EmailPurpose::NewAction)

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end

  # Safety check email whenever a user is deleted
  #
  def user_deleted(user)
    @user = user
    generate_attributes(0,0,@user,EmailPurpose::Admin)

    recipients    User.find_all_by_is_admin(true).first.email
    from          EMAILS[:contact]
    subject       @user.first_name + ", is deleted from OnCloset"
  end

  # Extend the method_missing method to enable email
  # delivery only in production environment
  #
  def self.method_missing(method,*args)

    if method.to_s.match(/^deliver_(.*)/)
      mail = self.send("create_#{$1}".to_sym,*args) 

      if RAILS_ENV == 'production' || 
                       User.find_by_email(mail['to'].to_s).is_admin

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
      mail.body
    else
      super
    end
  end


  protected 

  # Generate email attributes to store in the database
  #
  def generate_attributes(recipient_id,sender_id,source,purpose)
    @@attributes = {
                  :recipient_id   => recipient_id,
                  :sender_id      => sender_id,
                  :emailable_id   => source.id,
                  :emailable_type => source.class.name,
                  :purpose        => purpose}
  end

end
