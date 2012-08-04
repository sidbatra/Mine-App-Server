json.array! @stores do |json,store|
  json.extract! store, :id,:name,:domain
end
