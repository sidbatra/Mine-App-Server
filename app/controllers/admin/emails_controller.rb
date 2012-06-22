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
    
    when :after_join_suggestions
      suggestions = Suggestion.by_weight.limit(3)
      suggestions_done_ids = suggestions[0..1].map(&:id)

      render :text => UserMailer.preview_after_join_suggestions(User.last,suggestions,suggestions_done_ids)

    when :new_comment
      render :text => UserMailer.preview_new_comment(Comment.last,User.last)

    when :new_like
      render :text => UserMailer.preview_new_like(Like.last)

    when :friend_activity_digest
      render :text => UserMailer.preview_friend_activity_digest(
                                  User.find(3),
                                  User.find_all_by_id([1,2,13,12]),
                                  [Purchase.all[-5..-1],[Purchase.last]])

    when :user_deleted
      render :text => UserMailer.preview_user_deleted(User.first,User.last)

    end
  end
end
