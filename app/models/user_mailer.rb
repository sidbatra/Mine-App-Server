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
      @action    += " commented on your item"
    elsif @owner.id == @comment.user.id 
      @action    += " also commented on his item"
    else
      @action    += " also commented on #{@owner.first_name} "\
                    " #{@owner.last_name}'s item"
    end

    recipients    @user.email
    from          EMAILS[:contact]
    subject       @action #+ " " + rand(10000).to_s
  end

end
