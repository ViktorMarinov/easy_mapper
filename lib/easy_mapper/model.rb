require_relative 'query'
require_relative 'model/class_macros'
require_relative 'model/query_methods'
require_relative 'db_repository'
require_relative 'errors'

module EasyMapper
  module Model
    def self.included(cls)
      cls.extend ClassMacros
      cls.extend QueryMethods

      db_adapter = EasyMapper::Config.db_adapter
      cls.repository EasyMapper::DbRepository.new(cls, db_adapter)

      cls.class_exec do
        def initialize(initial_values = {})
          @object = initial_values.select do |key, _|
            self.class.attributes.include? key
          end

          all_associations = associations_to_one + associations_to_many
          defined_assoc_names = all_associations.map { |assoc| assoc.name }

          @associations = initial_values.select do |key, _|
            defined_assoc_names.include? key
          end

          associations_to_many
            .reject { |assoc| initial_values.include? assoc.name }
            .each do |assoc|
              @associations[assoc.name] = []
            end
        end
      end

      def save
        associations_to_one.each do |assoc_to_one|
          result = @associations[assoc_to_one.name].save
          @object[assoc_to_one.id_column] = result.id
        end

        if id
          repository.update(id, @object)
        else
          @object[:id] = repository.next_id
          repository.create(@object)
        end

        associations_to_many.each do |assoc_to_many|
          @associations[assoc_to_many.name].each do |model|
            model.public_send "#{assoc_to_many.mapped_by}=", id
            model.save
          end
        end

        self
      end

      def delete
        raise Errors::DeleteUnsavedRecordError unless id

        repository.delete(id: id)
      end

      def ==(other)
        return id == other.id if id && other.id
        equal? other
      end

      private

      def primary_keys
        self.class.primary_keys
      end

      def repository
        self.class.repository
      end

      def associations_to_many
        self.class.associations_to_many
      end

      def associations_to_one
        self.class.associations_to_one
      end
    end
  end
end
