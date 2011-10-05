# This is a different implementation of require_relative than the one
# supplied in the aws-2.5.6 codebase.  Theirs causes duplicate
# requires and the consequent "already initialized constant" warnings.

# see vendor/ruby/1.8/gems/aws-2.5.6/lib/awsbase/require_relative.rb
# and https://github.com/appoxy/aws/issues/84

unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(path)
      desired_path = File.expand_path('../' + path.to_str, caller[0])
      shortest = desired_path
      $:.each do |path|
        path += '/'
        if desired_path.index(path) == 0
          candidate = desired_path.sub(path, '')
          shortest = candidate if candidate.size < shortest.size
        end
      end
      require shortest
    end
  end
end
