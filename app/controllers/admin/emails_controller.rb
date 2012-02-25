class Admin::EmailsController < ApplicationController
  before_filter :admin_required

  # Display sample content of a particular email
  #
  def show
    case params[:id].to_sym

    when :new_follower
      render :text => UserMailer.preview_new_follower(Following.last)

    when :new_comment
      text = UserMailer.preview_new_comment(
                Comment.on_type(Collection.name).last,
                User.last)

      text += "<br><br><br><br>"

      text += UserMailer.preview_new_comment(
                Comment.on_type(Product.name).last,
                User.last)

      render :text => text

    when :new_action
      text = UserMailer.preview_new_action(
                Action.on_type(Collection.name).last)

      text += "<br><br><br><br>"

      text += UserMailer.preview_new_action(
                Action.on_type(Product.name).last)

      render :text => text

    when :user_deleted
      render :text => UserMailer.preview_user_deleted(User.last)

    when :top_shopper
      render :text => UserMailer.preview_top_shopper(
                        User.last,
                        Store.approved.last)
    end
  end
end
