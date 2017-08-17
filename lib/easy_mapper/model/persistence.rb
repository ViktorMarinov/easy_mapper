require_relative '../errors'

module EasyMapper 
  module Model
    module Persistence
      def save
        if id
          repository.update(@object)
        else
          self.id = repository.next_id
          repository.create(@object)
        end

        self
      end

      def delete
        if id
          repository.delete(id: id)
        else
          raise OhMapper::Errors::DeleteUnsavedRecordError
        end
      end

      private

      def repository
        self.class.repository
      end
    end
  end
end

