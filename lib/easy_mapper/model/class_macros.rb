require_relative '../query'

module EasyMapper
  module Model
    module ClassMacros
      def attributes(*attributes)
        return @attributes if attributes.empty?
        @attributes = attributes + [:id]

        @attributes.each do |attribute|
          define_singleton_method "find_by_#{attribute}" do |value|
            objects.where({attribute => value})
          end

          define_method(attribute) { @object[attribute] }
          define_method("#{attribute}=") { |value| @object[attribute] = value }
        end
      end

      def repository
        @repository
      end

      def repository=(repository)
        @repository = repository
      end
    end
  end
end

