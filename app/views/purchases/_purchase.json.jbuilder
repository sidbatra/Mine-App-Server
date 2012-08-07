json.extract! purchase,:id,:created_at,:title,:handle,:endorsement,:source_url,:giant_url,:fb_object_id

json.user do |j|
  j.partial! purchase.user 
end

json.store do |j|
  j.partial! purchase.store 
end if purchase.store

json.likes purchase.likes do |j,like|
  j.partial! like
end

json.comments purchase.comments do |j,comment|
  j.partial! comment
end