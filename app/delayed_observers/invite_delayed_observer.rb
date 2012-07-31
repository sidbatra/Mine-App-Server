class InviteDelayedObserver < DelayedObserver

  # Delayed after_create.
  #
  def self.after_create(invite_id)
    invite = Invite.find(invite_id)
    Mailman.send_invite(invite)
  end

end
