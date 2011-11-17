module DW
  
  # Methods, attributes and callbacks to be mixed in to
  # ActiveRecord models that require generate of unique handles
  #
  module Handler
    attr_accessor :generate_handle

    # Add callback after save to populate handle
    #
    def self.included(base)
      base.instance_eval("before_save :populate_handle")
    end


    protected

    # Populate handle for the model
    #
    def populate_handle
      return unless !self.handle.present? || self.generate_handle

      self.handle = handle_base.
                        gsub(/[^a-zA-Z0-9]/,'-').
                        squeeze('-').
                        chomp('-')
      
      self.handle = rand(1000000) if self.handle.empty?


      base  = self.handle
      tries = 1

      # Create uniqueness
      while(true)
        match = handle_uniqueness_query(base)
        break unless match.present? && match.id != self.id

        base = self.handle + '-' + tries.to_s
        tries += 1
      end

      self.handle = base
    end

  end # Handler
end # DW
