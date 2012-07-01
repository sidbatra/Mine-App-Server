module DW

  module QueueManagement


    class QueueManager

      # Public. Setup AWS credentials and connection_mode for the service.
      # 
      # aws_access_id - The String AWS access id.
      # aws_secret_key - The String AWS secret key.
      # connection_mode - The Symbol for threading options - 
      #                   :single,:per_thread,:per_request. 
      #                   See: https://github.com/appoxy/aws/ (default: :single)
      #
      def self.setup(aws_access_id,aws_secret_key,connection_mode=:single)
        @aws_access_id = aws_access_id
        @aws_secret_key = aws_secret_key
        @connection_mode = connection_mode
      end
        
      # Public. Open a connection and fetch an Aws::Sqs::Queue.
      #
      # Returns the Aws::Sqs::Queue.
      def self.fetch(name,visibility)
        Aws::Sqs::Queue.create(sqs,name,true,visibility)
      end


      private

      # Private: Getter method for Aws::Sqs object. Enables
      # lazily creating an SqsInterface.
      #
      # Returns the Aws::Sqs.
      def self.sqs
        @sqs ||= Aws::Sqs.new(
                  @aws_access_id,
                  @aws_secret_key,
                  {:connection_mode => @connection_mode})
      end

    end


    class Payload
      attr_accessor :queue
      attr_reader :attempts

      # Public. Create a payload with an object a method of that
      # object and optional arguments for that method.
      #
      # object - The Object the payload carries.
      # method - The Symbol method name for the object.
      # args - The optional array of arguments for the method.
      #
      # Returns nothing.
      # Raises ArgumentError if object or method aren't present.
      def initialize(object,method,*args)
        raise ArgumentError, "object and method required" unless object && method

        @attempts = 0
        @object = object.is_a?(Class) ? 
                    object.to_s.split("::").last :
                    object.to_yaml 
        @method = method
        @arguments = args
      end

      # Public. Call the method on the carried object with
      # the carried arguments. If the carried object is an
      # ActiveRecord::Base object, reload it from the db
      # to get a fresh state.
      #
      # Returns the result of the method call on the object.
      def process
        if @object.start_with? "--- "
          object = YAML.load(@object)

          if object.is_a? ActiveRecord::Base
            object = object.class.find object.id 
          end
        else
          object = Object.const_get(@object)
        end

        object.send(@method.to_sym,*@arguments)
      end

      # Public. Mark the instance as failed by increaseing
      # the number of attempts to process it.
      #
      # Returns the Integer number of attempts used.
      def failed
        @attempts += 1
      end

      # Public. Override to_s for a loggable output.
      #
      # Returns the String form of the Payload.
      def to_s
        output = ""

        if @object.start_with? "--- "
          object = YAML.load(@object)
          output << object.class.name 
        else
          output << Object.const_get(@object).name
        end

        output << " :#{@method} #{@arguments.join("|")}"
        output
      end

    end


    class Queue

      # Public. Constructor logic.
      #
      # name - The String name of the queue.
      # visibility - The Integer visibility of an item in the queue.
      #
      # Returns nothing.
      def initialize(name,visibility=90)
        @name = name
        @visibility = visibility
      end

      # Public. Pop the first entry in the queue and create a payload
      # object from it.
      #
      # Returns the Payload object if found or nil.
      def pop
        message = queue.pop

        if message
          payload = YAML.load(message.body) 
          payload.queue = self
        end

        payload
      end

      # Push a new entry onto the queue. 
      #
      # args - This can either be a Payload object or a Class or any ruby object
      # including ActiveRecord::Base objects followed by a symbol for a method and optional
      # method arguments. During processing ActiveRecord::Base
      # objects are fetched again from the DB to avoid staleness.
      #
      # Returns nothing.
      def push(*args)
        payload = nil

        if args.first.class == Payload
          payload = args.first
          payload.queue = nil
        else
          payload = Payload.new(*args)
        end

        queue.push(payload.to_yaml)
      end

      # Public: Clear all entries in the queue.
      #
      # Returns nothing.
      def clear
        queue.clear
      end


      private
      
      # Private. Getter method for the queue. Enables opening
      # lazy connections.
      #
      # Returns the Aws::Sqs::Queue object the QueueManager creates.
      def queue
        @queue ||= QueueManager.fetch(@name,@visibility)
      end

    end

  end #queue management

end #dw
