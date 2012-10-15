json.extract! notification,:id,:created_at,:entity,:event,:resource_type,:identifier,:image_url,:unread

json.user do |j|
  j.partial! "users/user", {:user => notification.resource}
end if notification.resource_type == User.name

json.purchase do |j|
  j.partial! "purchases/purchase", {:purchase => notification.resource,:without_interactions => true,:without_store => true}
end if notification.resource_type == Purchase.name

