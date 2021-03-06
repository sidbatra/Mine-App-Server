class FacebookSubscriptionsController < ApplicationController
  layout nil
  
  # Handle facebook related get requests for real time updates 
  #
  def index
    mode          = params['hub.mode']
    challenge     = params['hub.challenge']
    verify_token  = params['hub.verify_token']

    unless mode && challenge && verify_token == CONFIG[:fb_verify_token] 
      raise IOError, "Incorrect params for fb subscription verification" 
    end

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end 

  # Handle facebook related post requests for real time updates 
  #
  def create
  
    object  = params[:object]
    entry   = params[:entry]

    unless object && entry 
      raise IOError, "Incorrect params for fb subscription updates"
    end

    user_fb_ids = entry.map{|permission| permission['uid']} 
    users       = User.find_all_by_fb_user_id(user_fb_ids)
    users       = users.select do |user| 
                    user.visited_at && user.visited_at > 30.days.ago 
                  end
    
    if object == 'user'
      users.each do |user|
        ProcessingQueue.push(
          UserDelayedObserver,
          :mine_fb_data,
          user) 
      end 
    end

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end

end
