# Extensions of inbuilt classes

# Extension of the ActiveRecord Base class
#
class ActiveRecord::Base 
  named_scope :select, lambda {|*args| {:select => args.join(",")}}
  named_scope :made, lambda{|time_ago| {:conditions => {
                                          :created_at => time_ago..Time.now}}}
end

