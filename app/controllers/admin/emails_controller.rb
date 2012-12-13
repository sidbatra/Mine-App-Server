class Admin::EmailsController < ApplicationController
  layout 'admin'
  before_filter :admin_required

  # Display links to all emails
  #
  def index
  end

  # Display sample content of a particular email
  #
  def show
    case params[:id].to_sym

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

    when :new_follower
      render :text => UserMailer.preview_new_follower(Following.last)

    when :new_invite
      render :text => UserMailer.preview_new_invite(Invite.last(:conditions => {:platform => InvitePlatform::Email}))
      
   when :run_importer
      render :text => UserMailer.preview_run_importer(User.last)

   when :download_app
      render :text => UserMailer.preview_download_app(User.last)

   when :friend_imported
      render :text => UserMailer.preview_friend_imported(User.find(13),User.last)

   when :purchases_imported
      render :text => UserMailer.preview_purchases_imported(User.last,9)

    when :friend_activity_digest
      render :text => UserMailer.preview_friend_activity_digest(
                                  User.find(3),
                                  User.find_all_by_id([1,2,13,12]),
                                  User.find_all_by_id([12,99]),
                                  [Purchase.all[-5..-1],[Purchase.last]])
    
    when :add_purchase_reminder
      render :text => UserMailer.preview_add_purchase_reminder(User.first)

    when :feedback_offer
      render :text => UserMailer.preview_feedback_offer(User.find_by_purchases_count(2))

    when :news
      render :text => UserMailer.preview_news(User.first)

    when :user_deleted
      render :text => UserMailer.preview_user_deleted(User.first,User.last)

    end
  end
end
