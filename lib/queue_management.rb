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


    # The object pushed onto all the queues
    #
    class Payload
      attr_accessor :klass,:method,:attempts,:arguments

      # Initialize with klass name and method to be executed along
      # with optional arguments
      #
      def initialize(*args)
        raise IOError, "klass name needed" if args.size < 2
        
        @attempts   = 0
        @klass      = args.first.is_a?(ActiveRecord::Base) ? 
                        args.first.to_yaml  : 
                        args.first.to_s.split("::").last
        @method     = args[1]
        @arguments  = args[2..-1]
      end

      # Process the payload object by mapping to an object of the given
      # klass and running the given method with the given arguments
      #
      def process
        object = @klass.match(/ruby\/object/) ?
                  YAML.load(@klass) :
                  Object.const_get(@klass)

        if object.is_a? ActiveRecord::Base
          object = object.class.find object.id
        end

        object.send(@method.to_sym,*arguments)
      end

      # Returns an identifying name for the object
      #
      def object_name
        if @klass.match(/ruby\/object/)
          object = YAML.load(@klass)
          object.class.name + '_' + object.id.to_s
        else
          Object.const_get(@klass).name
        end
      end

      # Test based on the total attempts whether the payload should
      # receover from failure or not
      #
      def recover?
        @attempts += 1
        @attempts < CONFIG[:max_processing_attempts]
      end
    end


    class Queue

      # Public. Constructor logic.
      #
      # name - The String name of the queue.
      # visibility - The Integer visibility of an item in the queue.
      #
      def initialize(name,visibility=90)
        @name = name
        @visibility = visibility
      end

      # Return a new payload object if any exists in the queue
      #
      def pop
        message = queue.pop
        payload = YAML.load(message.body) if message
        payload
      end

      # Push a payload object onto the processing queue either by creating
      # a new one using its klass and an unlimited number of arguments
      # or by using an existing one
      #
      def push(*args)
        raise IOError, "klass name or payload needed" if args.size == 0

        payload = nil

        if args.first.class == Payload
          payload = args.first
        else
          payload = Payload.new(*args)
        end

        queue.push(payload.to_yaml)
      end

      # Public: Clear all entries in the queue.
      #
      def clear
        queue.clear
      end


      private
      
      # Private. Getter method for the queue. Enables opening
      # lazy connections.
      #
      def queue
        @queue ||= QueueManager.fetch(@name,@visibility)
      end

    end

  end #queue management

end #dw
