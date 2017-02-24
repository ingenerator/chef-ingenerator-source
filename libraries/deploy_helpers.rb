# Provides helper methods for interacting with the deployment during deploy
module Ingenerator
  module SourceDeployment
    class DeploymentManager
      # Assigned when the git checkout / etc is complete before symlinking
      @release_path = nil

      # Don't call this from external code
      def self.set_release_path(path)
        @release_path = path
      end

      class << self
        attr_reader :release_path
      end
    end

    module DeployHelpers
      class DeploymentNotReadyError < RuntimeError
        def initilize
          super
          "Your code attempted to access `this_release_path` before it had been set\n"\
          "This probably means you need to move your recipe later in execution\n"\
          '`this_release_path` is not set until the code has been checked out'
        end
      end

      # This method magically appears as a helper inside recipes, so you can
      # use it in your prepare_deploy hook recipe etc to access your checked-out
      # code before it goes live. If you call it before the code is there, it will
      # throw!
      def this_release_path
        path = Ingenerator::SourceDeployment::DeploymentManager.release_path
        raise DeploymentNotReadyError if path.nil?
        path
      end
    end
  end
end

Chef::Recipe.send(:include, Ingenerator::SourceDeployment::DeployHelpers)
