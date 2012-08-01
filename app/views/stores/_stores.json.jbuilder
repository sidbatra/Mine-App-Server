json.array! stores do |json,store|
  json.partial! store, :domain => true
end
