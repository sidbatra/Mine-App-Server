json.extract! like, :id

json.user do |j|
  j.partial! like.user
end

