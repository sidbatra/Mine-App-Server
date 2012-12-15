# Extensions of inbuilt classes

# Extension of the ActiveRecord Base class
#
class ActiveRecord::Base 
  named_scope :select, lambda {|*args| {:select => args.join(",")}}
  named_scope :group, lambda {|*args| {:group => args.join(",")}}
  named_scope :limit, lambda {|limit| {:limit => limit}}
  named_scope :offset, lambda {|offset| {:offset => offset}}
  named_scope :made, lambda{|*args| {:conditions => {
                                          :created_at => args.first..(args[1] ? args[1] : Time.now)}}}
  named_scope :after, lambda{|time| {:conditions => {
                                          :created_at_gt => time}} if time}
  named_scope :before, lambda{|time| {:conditions => {
                                          :created_at_lt => time}} if time}
  named_scope :updated, lambda{|time_ago| {:conditions => {
                                          :updated_at => time_ago..Time.now}}}
end

# Override the default datetime format in json.
#
class ActiveSupport::TimeWithZone
   def as_json(options = {})
     strftime('%Y-%m-%d %H:%M:%S %z')
   end
 end

# Extension of ruby's Array class
#
#class Array
#
#  # Public. Convert the array into a hash with each entry
#  # in the array becoming a key and true becoming the value.
#  #
#  # Returns the Hash formed from the array.
#  #
#  #def to_hash
#  #  Hash[*self.zip([true] * self.length).flatten]
#  #end
#
#end

class String
  
  # Convert only the first character to upcase
  #
  def firstupcase
    result = ""
    result = self[0..0].upcase + self[1..-1] unless self.length.zero?
    result
  end
end
