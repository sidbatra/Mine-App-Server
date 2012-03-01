# Receive delayed events on the invite model
#
class InviteDelayedObserver < DelayedObserver

  # Delayed after_create
  #
  def self.after_create(invite_id)
    invite = Invite.find(invite_id)

    # Assuming name has atleast 2 parts
    name_parts = invite.recipient_name.split(' ')

    user = User.add_from_invite({
            :fb_user_id => invite.recipient_id,
            :first_name => name_parts.first,
            :last_name  => name_parts[1..-1].join(' '),
            :byline     => invite.byline})

    if user.valid?
      Following.add(user.id,invite.user_id,FollowingSource::Invite,false)
      Following.add(invite.user_id,user.id,FollowingSource::Invite,false)

      # Create invite
      sender = User.find(invite.user_id)
      sender.post_on_friends_fb_wall(user)
    end
  end

end
