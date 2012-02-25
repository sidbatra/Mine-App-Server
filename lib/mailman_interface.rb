module DW

  # Set of classes and methods for interfacing with the email service
  #
  module MailmanInterface

    # Mailman wraps around UserMailer and abstracts the logic
    # to generate complex emails
    #
    class Mailman

      # Email all the users on the comment thread
      #
      def self.new_comment(comment)
        user_ids  = Comment.user_ids_in_thread_with(comment)
        users     = User.find_all_by_id(user_ids)

        users.each do |user|
          UserMailer.deliver_new_comment(
                      comment,
                      user) unless user.id == comment.user.id
        end
      end

      # Email user being followed
      #
      def self.new_following(following)
        UserMailer.deliver_new_follower(following) 
      end

      # Email the owner about any action on a collection or product
      #
      def self.new_action(action)
        UserMailer.deliver_new_action(
                    action) unless action.user_id == action.actionable.user_id
      end
    end #mailman

  end #mailman module

end #dw
