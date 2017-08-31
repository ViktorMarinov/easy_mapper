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

          all_associations = has_one_assoc + has_many_assoc
          defined_assoc_names = all_associations.map { |assoc| assoc.name }

          @associations = initial_values.select do |key, _|
            defined_assoc_names.include? key
          end

          has_many_assoc
            .reject { |assoc| initial_values.include? assoc.name }
            .each do |assoc|
              @associations[assoc.name] = []
            end
        end
      end

      def save
        has_one_assoc.each do |assoc|
          result = @associations[assoc.name].save
          @object[assoc.id_column] = result.id
        end

        if id
          repository.update(id, @object)
        else
          @object[:id] = repository.next_id
          repository.create(@object)
        end

        has_many_assoc.each do |assoc|
          association = @associations[assoc.name]
          @associations[assoc.name] = association.map { |model| model.save }
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

      def has_many_assoc
        self.class.has_many_assoc
      end

      def has_one_assoc
        self.class.has_one_assoc
      end
    end
  end
end
