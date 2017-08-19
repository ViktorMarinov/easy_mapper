require_relative '../errors'

module EasyMapper
  module Model
    module Persistence
      def save
        puts "PKS ARE #{primary_keys}"
        if has_pk
          repository.upsert(@object)
        else
          repository.create(@object)
        end

        self
      end

      def delete
        if has_pk
          query = @object.select { |key, _| primary_keys.include? key }
        else
          query = @object
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

