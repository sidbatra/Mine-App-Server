class UserDelayedObserver < DelayedObserver

  # Delayed after_create
  #
  def self.after_create(user_id)
    user = User.find(user_id)

    Mailman.welcome_new_user(user)

    after_fb_permissions_update(user.id)
    mine_fb_data(user)
  end

  # Delayed after_update
  #
  def self.after_update(user_id,options={})
    user = User.find(user_id)

    mine_fb_data(user) if options[:mine]
  end

  # Delayed facebook permissions update 
  #
  def self.after_fb_permissions_update(user_id)
    user        = User.find(user_id)

    permissions = user.fb_permissions
    setting     = user.setting

    setting.fb_publish_stream   = permissions.include?(:publish_stream)
    setting.fb_publish_actions  = permissions.include?(:publish_actions)
    
    setting.save!
  end


  protected

  # Mine user's fb data
  #
  def self.mine_fb_data(user)
    fb_friends        = user.fb_friends

    fb_friends_ids    = fb_friends.map(&:identifier)
    fb_friends_names  = fb_friends.map(&:name)

    followers         = User.find_all_by_fb_user_id(fb_friends_ids)

    followers.each do |follower|
      Following.add(user.id,follower.id,FollowingSource::Auto,false)
      Following.add(follower.id,user.id,FollowingSource::Auto)
    end

    Contact.batch_insert(user.id,fb_friends_ids,fb_friends_names)

    user.has_contacts_mined = true
    user.save!
  end

end
