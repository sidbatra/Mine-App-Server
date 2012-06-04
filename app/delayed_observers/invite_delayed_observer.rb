class InviteDelayedObserver < DelayedObserver

  # Delayed after_create.
  #
  def self.after_create(invite_id)
    invite = Invite.find(invite_id)
    sender = User.find(invite.user_id)

    DistributionManager.post_invite_on_friends_wall(sender,invite.recipient_id)
  end

end
