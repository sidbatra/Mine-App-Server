# Handle user related requests for admin view
#
class Admin::UsersController < ApplicationController
  before_filter :admin_required

  # Show all the users who have created a product
  # 
  def index 
    @users            = Product.eager.all.map(&:user).uniq
    @grouped_users    = {} 

    @users.each do |user| 
      key = user.age/CONFIG[:age_bucket_size]
      @grouped_users[key] = [] unless @grouped_users.has_key?(key)
      @grouped_users[key] = @grouped_users[key] << user 
    end

    @grouped_users = @grouped_users.sort{|a,b| a[0]<=>b[0]}
  end


  # Display the user's queries and products. 
  #
  def show
    user      = User.find(params[:id])

    @queries  = user.searches.map(&:query)
    @products = user.products.map(&:query)
  end

end
