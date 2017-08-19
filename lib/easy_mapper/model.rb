require_relative 'query'
require_relative 'model/class_macros'
require_relative 'model/query_methods'
require_relative 'model/persistence'
require_relative 'repository'

module EasyMapper
  module Model
    def self.included(cls)
      cls.extend ClassMacros
      cls.extend QueryMethods
      cls.include Persistence

      cls.class_exec do
        def initialize(initial_values = {})
          @object = initial_values.select do |key, _|
            self.class.attributes.include? key
          end
        end
      end

      cls.repository = Repository.new(cls)
    end
  end
end
