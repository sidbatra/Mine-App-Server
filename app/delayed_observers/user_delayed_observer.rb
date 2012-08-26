class UserDelayedObserver < DelayedObserver

  # Delayed after_create
  #
  def self.after_create(user_id)
    user = User.find(user_id)

    Mailman.welcome_new_user(user)

    mine_fb_data(user)
    mine_tw_data(user)
  end

  # Delayed after_update
  #
  def self.after_update(user_id,options={})
    user = User.find(user_id)

    mine_fb_data(user) if options[:mine_fb_data]
    mine_tw_data(user) if options[:mine_tw_data]
  end

  # Mine user's fb data
  #
  def self.mine_fb_data(user)
    return unless user.fb_access_token_valid?

    mine_fb_info(user)
    mine_fb_friends(user)
  end

  # Mine additional data about the user from the twitter api.
  #
  def self.mine_tw_data(user)
    return unless user.tw_authorized?

    mine_tw_connections(user)
  end


  protected

  # Auto follow Mine users that the user is already following on
  # twiter. Also make all users on Mine following the user auto 
  # follow him/her.
  #
  def self.mine_tw_connections(user)
    client = Twitter::Client.new(
                  :consumer_key => CONFIG[:tw_consumer_key],
                  :consumer_secret => CONFIG[:tw_consumer_secret],
                  :oauth_token => user.tw_access_token,
                  :oauth_token_secret => user.tw_access_token_secret)

    existing_friends = User.find_all_by_tw_user_id(client.friend_ids.ids)

    existing_friends.each do |existing_friend|
      Following.add(
        existing_friend.id,
        user.id,
        FollowingSource::Auto,
        false,
        false)
    end


    existing_followers = User.find_all_by_tw_user_id(client.follower_ids.ids)

    existing_followers.each do |existing_follower|
      Following.add(
        user.id,
        existing_follower.id,
        FollowingSource::Auto,
        false,
        false)
    end

  rescue => ex
    LoggedException.add(__FILE__,__method__,ex)
  end

  # Mine user's facebook info.
  #
  def self.mine_fb_info(user)
    fb_user = FbGraph::User.fetch("me?fields=birthday",
                :access_token => user.access_token)

    user.birthday = fb_user.birthday
    user.save!
  end
  
  # Mine user's facebook friends to populate contacts
  # and existing friends on the app.
  #
  def self.mine_fb_friends(user)

    fb_friends        = user.fb_friends

    fb_friends_ids    = fb_friends.map(&:identifier)
    fb_friends_names  = fb_friends.map(&:name)

    followers         = User.find_all_by_fb_user_id(fb_friends_ids)

    followers.each do |follower|
      Following.add(user.id,follower.id,FollowingSource::Auto,false,false)
      Following.add(follower.id,user.id,FollowingSource::Auto,false,false)
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
