json.extract! user, :id,:handle,:first_name,:last_name,:gender,:square_image_url,:large_image_url,:byline,:email,:age,:purchases_count,:followings_count,:inverse_followings_count

if defined? sensitive
  json.extract! user, :unread_notifications_count,:access_token,:tw_access_token,:tw_access_token_secret,:tumblr_access_token,:tumblr_access_token_secret,:iphone_device_token,:is_email_authorized 
  json.sensitive true
end

json.setting do |j|
  j.extract! user.setting, :id, :share_to_facebook, :share_to_twitter, :share_to_tumblr
end if defined? setting
