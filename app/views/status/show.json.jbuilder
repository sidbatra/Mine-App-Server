json.user do |j|
  j.partial! "users/userfull", :user => self.current_user, :setting => true, :sensitive => true
end
