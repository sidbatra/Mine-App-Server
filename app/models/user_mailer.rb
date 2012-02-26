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
      @action    += "just commented on your "
    elsif @owner.id == @comment.user.id 
      @action    += " also commented on #{@owner.is_male? ? 'his' : 'her'} "
    else
      @action    += " also commented on #{@owner.first_name} "\
                    " #{@owner.last_name}'s "
    end

    if(comment.commentable_type == 'Product')
      @action     += comment.commentable.title
    elsif(comment.commentable_type == 'Collection')
      @action     +=  comment.commentable.name.present? ? 
                        "\"#{comment.commentable.name.strip}\" set" : "set"
    end

    @action	    += "!"

    generate_attributes(@user.id,@comment.user.id,@comment,EmailPurpose::NewComment)

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action 
  end

  # Alert user when someone starts following him/her
  #
  def new_follower(following) 
    @follower     = following.follower 
    @user         = following.user

    @action       = @follower.first_name + " " + @follower.last_name + 
                    " thinks you influence each other's style!"

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
    @action       = "#{@owner.first_name} #{@owner.last_name} " + 
                    "just posted a new set!" 

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
                     'want' => 'added'}

    @actionable   = action.actionable
    @user         = @actionable.user 
    @actor        = action.user 
    @action_name  = action.name

    @action       = "#{@actor.first_name} #{@actor.last_name} " + 
    								"#{action_map[@action_name]} your "

    if(@actionable.class.name == 'Product')
      @action     +=  @actionable.title
    elsif(@actionable.class.name == 'Collection')
      @action     +=  @actionable.name.present? ? 
                        "\"#{@actionable.name.strip}\" set" : "set"
    end
    
    if @action_name == 'want'
    	@action			+= " to #{@actor.is_male? ? 'his' : 'her'} Wants!"
    else
    	@action			+= "!"
    end

    generate_attributes(@user.id,@actor.id,action,EmailPurpose::NewAction)

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end

  # Alert the user to create daily collections 
  #
  def create_another_collection(user,last_collection)
    @user             = user
    @last_collection  = last_collection
    @products         = last_collection.products.map(&:title)

    @action           = "Still have your "

    if @products.length == 1
      @action         += @products[0]
    else
      @action         += "#{@products[0..-2].join(", ")} and #{@products[-1]}" 
    end

    @action           += " on you?"
                  
    generate_attributes(@user.id,0,@last_collection,EmailPurpose::AnotherCollection)

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end

  # Alert the user to add new products to their closet 
  #
  def create_another_product(user)
    @user         = user
    @action       = "Bought something new this week?"

    generate_attributes(@user.id,0,@user,EmailPurpose::AnotherProduct)

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end
  
  # Alert the user to start adding items 
  #
  def add_an_item(user)
    @user         = user
    @action       = "Are you wearing your favorite shoes?"

    generate_attributes(@user.id,0,@user,EmailPurpose::AddItem)

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end

  # Alert the user to start inviting friends 
  #
  def add_a_friend(user)
    @user         = user
    @action       = "Which of your friends has great style?"

    generate_attributes(@user.id,0,@user,EmailPurpose::AddFriend)

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end

  # Alert the user to start adding stores 
  #
  def add_a_store(user)
    @user         = user
    @action       = "Where do you like to shop?"

    generate_attributes(@user.id,0,@user,EmailPurpose::AddStore)

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end

  # Alert the user to start adding collections 
  #
  def add_a_collection(user)
    @user         = user
    @action       = "Share your style!"

    generate_attributes(@user.id,0,@user,EmailPurpose::AddCollection)

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
      "<b>" + mail.subject + "</b>" + "<br><br>" + mail.body
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
