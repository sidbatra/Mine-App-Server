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


    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action #+ " " + rand(10000).to_s
  end

  # Alert user when someone starts following him/her
  #
  def new_follower(follower,user) 
    @follower     = follower
    @user         = user
    @action       = @follower.first_name + " " + @follower.last_name + 
                    " is now following you!"

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end

  # Alert user whenever he/she is featured as a star user 
  #
  def star_user(user)
    @user         = user
    @action       = "Your closet is now featured as a Top Closet!"

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

    @owner        = action.product.user 
    @user         = action.user 
    @product      = action.product
    @action_name  = action.name

    @action       = "#{@user.first_name} #{@user.last_name} " + 
    								"#{action_map[@action_name]} your #{@product.title}"
    
    if @action_name == 'want'
    	@action			+= " to #{@user.is_male? ? 'his' : 'her'} wishlist!"
    else
    	@action			+= "!"
    end

    recipients    @owner.email
    from          EMAILS[:contact]
    subject       @action
  end

  # Extend the method_missing method to enable email
  # delivery only in production environment
  #
  def self.method_missing(method,*arguments)
    method_name   = method.to_s
    regex         = Regexp.new('\Adecide')

    if method_name.scan(regex).present?
      if RAILS_ENV != 'development'
        new_method = method_name.gsub(regex,'deliver')
        self.send(new_method.to_sym,*arguments)
      else
        new_method = method_name.gsub(regex,'create')
        ActiveRecord::Base.logger.info "Preview of email generated \n\n" + 
                                    self.send(new_method.to_sym,*arguments).to_s
      end
    else
      super
    end
  end

end
