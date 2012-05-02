# Extensions of inbuilt classes

# Extension of the ActiveRecord Base class
#
class ActiveRecord::Base 
  named_scope :select, lambda {|*args| {:select => args.join(",")}}
  named_scope :limit, lambda {|limit| {:limit => limit}}
  named_scope :offset, lambda {|offset| {:offset => offset}}
  named_scope :made, lambda{|time_ago| {:conditions => {
                                          :created_at => time_ago..Time.now}}}
  named_scope :after, lambda{|time| {:conditions => {
                                          :created_at_gt => time}} if time}
  named_scope :before, lambda{|time| {:conditions => {
                                          :created_at_lt => time}} if time}
  named_scope :updated, lambda{|time_ago| {:conditions => {
                                          :updated_at => time_ago..Time.now}}}
end


# Extension of ruby's Array class
#
class Array

  # Public. Convert the array into a hash with each entry
  # in the array becoming a key and true becoming the value.
  #
  # Returns the Hash formed from the array.
  #
  def to_hash
    Hash[*self.zip([true] * self.length).flatten]
  end

end
