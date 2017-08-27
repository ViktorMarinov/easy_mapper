require_relative '../query'

module EasyMapper
  module Model
    module ClassMacros
      def attributes(*attributes)
        return @attributes if attributes.empty?
        @attributes = attributes

        @attributes.each do |attribute|
          define_singleton_method "find_by_#{attribute}" do |value|
            objects.where(attribute => value)
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

      def primary_keys(*pk_list)
        return @primary_keys if pk_list.empty?
        @primary_keys = pk_list
      end

      def table_name(name = nil)
        return @table_name unless name
        @table_name = name
      end
    end
  end
end
