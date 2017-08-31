require_relative '../query'
require_relative '../associations/has_one'
require_relative '../associations/has_many'
require_relative '../associations/belongs_to'

module EasyMapper
  module Model
    module ClassMacros
      attr_accessor :associations_to_many

      def attributes(*attributes)
        return @attributes if attributes.empty?
        @attributes = attributes + [:id]

        @attributes.each do |attribute|
          define_singleton_method "find_by_#{attribute}" do |value|
            objects.where(attribute => value).exec
          end

          create_attr_accessor(attribute)
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

      def has_one(attr_name, cls:, column: nil)
        association = Associations::HasOne.new(attr_name, cls, column)
        associations_to_one << association

        create_association_accessor(attr_name)
      end

      def has_many(attr_name, cls:, mapped_by: nil)
        association = Associations::HasMany.new(attr_name, cls, mapped_by)
        associations_to_many << association

        create_association_accessor(attr_name)
      end

      def belongs_to(cls, attr_name:, id_column: nil)
        id_column = "#{attr_name}_id" unless id_column
        association = Associations::BelongsTo.new(cls, attr_name, id_column)

        create_association_accessor(attr_name)
        create_attr_accessor(id_column)
      end

      def associations_to_one
        @associations_to_one = [] unless @associations_to_one
        @associations_to_one
      end

      def associations_to_many
        @associations_to_many = [] unless @associations_to_many
        @associations_to_many
      end

      private

      def create_attr_accessor(attribute)
        define_method(attribute) { @object[attribute] }
        define_method("#{attribute}=") { |value| @object[attribute] = value }
      end

      def create_association_accessor(name)
        define_method(name) { @associations[name] }
        define_method("#{name}=") { |value| @associations[name] = value }
      end
    end
  end
end
