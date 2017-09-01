module EasyMapper
  module Associations
    class BelongsTo
      attr_accessor :cls, :id_column

      def initialize(cls, attribute_name, id_column)
        @cls = cls
        @attribute_name = attribute_name
        @id_column = id_column
      end
    end
  end
end
