# Emailer interface for generating and sending
# emails to users
#
class UserMailer < ActionMailer::Base
  layout 'email'
  
  # Alert user when a new comment is added on a 
  # thread to which the user belongs
  #
  def new_comment(comment,user)
    @owner        = comment.product.user
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

    @action     += comment.product.title

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
                    " is now following you on Felvy!"

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end

  # Alert user whenever he/she is featured as a star user 
  #
  def star_user(user)
    @user         = user
    @action       = "You are now the star user on Felvy"

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
    @action       = "You are now the top shopper at #{@store.name}" 

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end

  # Alert the owner whenever an action is taken 
  # on his/her product
  #
  def new_action(action)
    action_map    = {'like' => 'liked',
                     'own'  => 'owned',
                     'want' => 'wants'}

    @owner        = action.product.user 
    @user         = action.user 
    @product      = action.product

    @action       = "#{@user.first_name} #{@user.last_name} 
                    #{action_map[action.name]} your #{@product.title} on Felvy!"

    recipients    @owner.email
    from          EMAILS[:contact]
    subject       @action
  end

end
