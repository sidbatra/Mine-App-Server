json.extract! purchase,:id,:bought_at,:title,:handle,:endorsement,:source_url,:giant_url,:fb_object_id
json.created_at purchase.bought_at
json.buyers_count purchase[:buyers_count] if purchase[:buyers_count]
json.message purchase[:message] if purchase[:message]

json.user do |j|
  j.partial! purchase.user 
end

json.store do |j|
  j.partial! purchase.store 
end if !defined?(without_store) && purchase.store

json.likes (defined?(without_interactions) ? [] : purchase.likes) do |j,like|
  j.partial! like
end 

json.comments (defined?(without_interactions) ? [] : purchase.comments) do |j,comment|
  j.partial! comment
end 
