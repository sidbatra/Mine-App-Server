class Admin::EmailsController < ApplicationController
  before_filter :admin_required

  # Display links to all emails
  #
  def index
  end

  # Display sample content of a particular email
  #
  def show
    case params[:id].to_sym

    when :new_follower
      render :text => UserMailer.preview_new_follower(Following.last)

    when :new_user
      render :text => UserMailer.preview_new_user(User.last)

    when :top_shopper
      render :text => UserMailer.preview_top_shopper(
                        User.last,
                        Store.approved.last)

    when :create_another_product
      render :text => UserMailer.preview_create_another_product(
                        User.last)

    when :add_an_item
      render :text => UserMailer.preview_add_an_item(User.last)

    when :add_a_friend
      render :text => UserMailer.preview_add_a_friend(User.last)

    when :add_a_store
      render :text => UserMailer.preview_add_a_store(User.last)

    when :friend_activity_digest
      render :text => UserMailer.preview_friend_activity_digest(
                                  User.find(3),
                                  User.find_all_by_id([1,2]),
                                  [Product.all[-5..-1],[Product.last]],
                                  [Product.find_all_by_id([100,102]), nil])

    when :user_deleted
      render :text => UserMailer.preview_user_deleted(User.first,User.last)

    end
  end
end
