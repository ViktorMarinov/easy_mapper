module EasyMapper
  module Associations
    class HasOne
      attr_accessor :name, :cls, :id_column

      def initialize(name, cls, id_column = nil)
        @name = name
        @cls = cls

        id_column = "#{name}_id" unless id_column
        @id_column = id_column
      end
    end
  end
end
