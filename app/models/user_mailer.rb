# Emailer interface for generating and sending
# emails to users
#
class UserMailer < ActionMailer::Base
  layout 'email'

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
    end

    generate_attributes(@user.id,@comment.user.id,@comment,'new_comment')

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

    generate_attributes(@user.id,@follower.id,following,'new_follower')

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end

  # Alert user about new bulk followers
  #
  def new_bulk_followers(user,followings) 
    @user         = user
    @followers    = followings.map(&:follower) 

    @action       = "#{@followers.length} new people are now following "\
                    "your Closet!" 
                    
    generate_attributes(@user.id,0,@user,'new_bulk_followers')

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end

  # Alert user whenever he/she is featured as a star user 
  #
  def star_user(user)
    @user         = user
    @action       = "Your closet is now featured as a Top Closet!"

    generate_attributes(@user.id,0,@user,'star_user')

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

    generate_attributes(@user.id,0,@store,'top_shopper')

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end

  # Alert the owner whenever an action is taken 
  # on his/her product
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
    end
    
    if @action_name == 'want'
    	@action			+= " to #{@actor.is_male? ? 'his' : 'her'} wishlist!"
    else
    	@action			+= "!"
    end

    generate_attributes(@user.id,@actor.id,action,'new_action')

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end

  # Revive a dormant user
  #
  def dormant(user)
    @user = user

    generate_attributes(@user.id,0,@user,'dormant')

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @user.first_name + ", your online closet is waiting!"
  end

  # Message about on today feature
  #
  def ontoday(user)
    @user = user

    generate_attributes(@user.id,0,@user,'ontoday')

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @user.first_name + ", come see an amazing update to your online closet!"
  end

  # Message user to keep creating collections
  #
  def collect_more(user)
    @user = user

    generate_attributes(@user.id,0,@user,'collect_more')

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @user.first_name + ", a Thank You message from OnCloset"
  end

  # Message user to invite more friends
  #
  def invite_more(user)
    @user = user
    generate_attributes(@user.id,0,@user,'invite_more')

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @user.first_name + ", your Closet is feeling lonely :o("
  end

  # Extend the method_missing method to enable email
  # delivery only in production environment
  #
  def self.method_missing(method,*args)

    if method.to_s.match(/^deliver_(.*)/)
      mail = self.send("create_#{$1}".to_sym,*args) 

      if RAILS_ENV == 'production'
        response    = @@custom_amazon_ses_mailer.send_raw_email(mail)
        xml         = XmlSimple.xml_in(response.to_s)

        message_id  = xml['SendRawEmailResult'][0]['MessageId'][0]
        request_id  = xml['ResponseMetadata'][0]['RequestId'][0]

        Email.add(@@attributes,message_id,request_id)
      else
        ActiveRecord::Base.logger.info "Preview of email generated \n\n" + 
                                        mail.to_s 
      end
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
