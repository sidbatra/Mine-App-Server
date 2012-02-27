module DW

  # Set of classes and methods for handling series of global
  # queues used across the application
  #
  module QueueManagement


    # System's interface to the creation, retrieval and deletion of queues
    #
    class QueueManager

      @@sqs = Aws::Sqs.new(
                CONFIG[:aws_access_id],
                CONFIG[:aws_secret_key],
                {:connection_mode => :single})
      

      # Returns a local queue object based on the given suffix. Local queues
      # have a prefix of the environment type and the machine_id
      #
      def self.fetch_local_queue(suffix,visibility)
        name = [RAILS_ENV,CONFIG[:machine_id],suffix].join("_") 

        puts name
        puts visibility

        Aws::Sqs::Queue.create(@@sqs,name,true,visibility)
      end

      # Returns a global queue object based on the given suffix. Global
      # queue objects have a prefix for the current environment and are
      # shared across the application framework
      #
      def self.fetch_global_queue(suffix,visibility)
        name = [RAILS_ENV,suffix].join("_") 

        puts name
        puts visibility

        Aws::Sqs::Queue.create(@@sqs,name,true,visibility)
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


    # Base Queue object overriden to create specific queue. 
    # The @@queue class variable is overriden in each child class
    # to specify a queue object provided by QueueManager
    #
    class Queue

      @@queue = nil

      # Return a new payload object if any exists in the queue
      #
      def self.pop
        message = @@queue.pop
        payload = YAML.load(message.body) if message
        payload
      end

      # Push a payload object onto the processing queue either by creating
      # a new one using its klass and an unlimited number of arguments
      # or by using an existing one
      #
      def self.push(*args)
        raise IOError, "klass name or payload needed" if args.size == 0

        payload = nil

        if args.first.class == Payload
          payload = args.first
        else
          payload = Payload.new(*args)
        end

        @@queue.push(payload.to_yaml)
      end

      # Clear the queue
      #
      def self.clear
        @@queue.clear
      end

    end


    # Inheirted from the Queue class, ProcessingQueue is the primary glue 
    # between most components of the application and has a dedicated server
    # with multiple workers processing its entries
    #
    class ProcessingQueue < Queue

      if Rails.env != 'development'
        @@queue = QueueManager.fetch_global_queue(Q[:proc],90)
      else
        @@queue = QueueManager.fetch_local_queue(Q[:proc],90)
      end
    end


  end #queue management

end #dw
