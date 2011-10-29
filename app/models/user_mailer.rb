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
      @action    += " also commented on his "
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
                    " started following you on Felvy"

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action
  end
end
