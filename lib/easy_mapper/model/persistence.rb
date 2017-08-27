require_relative '../errors'

module EasyMapper
  module Model
    module Persistence
      def save
        if has_pk
          repository.upsert(@object)
        else
          repository.create(@object)
        end

        self
      end

      def delete
        query = if has_pk
                  @object.select { |key, _| primary_keys.include? key }
                else
                  @object
                end

        repository.delete(query)
      end

      private

      def primary_keys
        self.class.primary_keys
      end

      def has_pk
        primary_keys && !primary_keys.empty?
      end

      def repository
        self.class.repository
      end
    end
  end
end
