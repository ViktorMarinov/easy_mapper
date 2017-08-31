module EasyMapper
  module Errors

    class EasyMapperError < StandardError
    end

    class DeleteUnsavedRecordError < EasyMapperError
    end

    class UnknownAttributeError < EasyMapperError
      def initialize(attribute_name)
        super "Unknown attribute #{attribute_name}"
      end
    end

    class NoDatabaseConnectionError < EasyMapperError
    end

    class AnonymousClassError < EasyMapperError
      def initialize
        super 'Anonymous classes must provide a table name'
      end
    end
  end
end
