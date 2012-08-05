json.extract! comment, :id, :message

json.user do |j|
  j.partial! comment.user
end


