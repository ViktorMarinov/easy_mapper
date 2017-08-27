module EasyMapper
  module Errors
    class DeleteUnsavedRecordError < StandardError
    end

    class UnknownAttributeError < StandardError
      def initialize(attribute_name)
        super "Unknown attribute #{attribute_name}"
      end
    end

    class NoDatabaseConnectionError < StandardError
    end

    class AnonymousClassError < StandardError
      def initialize
        super 'Anonymous classes must provide a table name'
      end
    end
  end
end
