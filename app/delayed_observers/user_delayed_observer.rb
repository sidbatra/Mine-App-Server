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

  # Mine user's fb data
  #
  def self.mine_fb_data(user,check=false)

    return if(check && user.fb_access_token_valid?)

    mine_fb_friends(user)
    compute_friend_score(user)
  end

  protected
  
  # Mine user's facebook friends to populate contacts
  # and existing friends on the app.
  #
  def self.mine_fb_friends(user)
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

  rescue => ex
    LoggedException.add(__FILE__,__method__,ex)
  end

  # Compute a weight for each contact fetched from facebook.
  #
  def self.compute_friend_score(user)
    contacts = Contact.select(:third_party_id).
                for_user(user.id).
                map(&:third_party_id)
    contacts = Hash[*contacts.zip([true] * contacts.length).flatten]
    weights = Hash.new(0)

    fb_user = FbGraph::User.new('me', :access_token => user.access_token)
    photos = fb_user.photos(:limit => 75)

    photos.each do |photo|
      next if photo.tags.length > 7

      photo.likes.each do |like| 
        weights[like.identifier] += 1
      end


      comment_hash = Hash.new(0)

      photo.comments.each do |comment| 
        next unless comment.from

        id = comment.from.identifier

        unless comment_hash.key? id
          weights[id] += 3 
          comment_hash[id] = true
        end
      end


      photo.tags.each do |tag| 
        weights[tag.user.identifier] += 5 if tag.user
      end
    end

    columns = [:user_id,:third_party_id,:weight]
    values = []

    weights.each do |fb_user_id,weight|
      values << [user.id,fb_user_id,weight] if contacts.key? fb_user_id
    end

    Contact.import(
      columns,
      values, {
        :validate => false,
        :timestamps => false,
        :on_duplicate_key_update => [:weight]}) if values.present?

  rescue => ex
    LoggedException.add(__FILE__,__method__,ex)
  end

end
