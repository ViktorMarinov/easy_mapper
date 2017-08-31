require_relative '../query'
require_relative '../associations/has_one'
require_relative '../associations/has_many'

module EasyMapper
  module Model
    module ClassMacros
      attr_accessor :has_many_assoc

      def attributes(*attributes)
        return @attributes if attributes.empty?
        @attributes = attributes + [:id]

        @attributes.each do |attribute|
          define_singleton_method "find_by_#{attribute}" do |value|
            objects.where(attribute => value).exec
          end

          define_method(attribute) { @object[attribute] }
          define_method("#{attribute}=") { |value| @object[attribute] = value }
        end
      end

      def repository(repository = nil)
        return @repository unless repository

        @repository = repository
      end

      def table_name(name = nil)
        return @table_name unless name
        @table_name = name
      end

      def has_one(attr_name, cls: , column: nil)
        association = Associations::HasOne.new(attr_name, cls, column)
        has_one_assoc << association

        create_association_accessor(attr_name)
      end

      def has_many(attr_name, cls: , mapped_by: nil)
        association = Associations::HasMany.new(attr_name, cls, mapped_by)

        has_many_assoc << association

        create_association_accessor(attr_name)
      end

      def has_one_assoc
        @has_one_assoc = [] unless @has_one_assoc
        @has_one_assoc
      end

      def has_many_assoc
        @has_many_assoc = [] unless @has_many_assoc
        @has_many_assoc
      end

      private

      def create_association_accessor(name)
        define_method(name) { @associations[name] }
        define_method("#{name}=") { |value| @associations[name] = value }
      end
    end
  end
end
