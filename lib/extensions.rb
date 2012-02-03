# Extensions of inbuilt classes

# Extension of the ActiveRecord Base class
#
class ActiveRecord::Base 
  named_scope :select, lambda {|*args| {:select => args.join(",")}}
end

