json.extract! user, :id,:handle,:first_name,:last_name,:gender,:square_image_url,:large_image_url,:byline,:email,:age,:purchases_count,:followings_count,:inverse_followings_count,:is_mining_purchases,:email_mining_metadata

if defined? sensitive
  json.extract! user, :unread_notifications_count,:access_token,:tw_access_token,:tw_access_token_secret,:tumblr_access_token,:tumblr_access_token_secret,:iphone_device_token,:is_google_authorized,:is_yahoo_authorized,:is_hotmail_authorized,:is_email_authorized
  json.sensitive true
end

json.setting do |j|
  j.extract! user.setting, :id, :share_to_facebook, :share_to_twitter, :share_to_tumblr
end if defined? setting
