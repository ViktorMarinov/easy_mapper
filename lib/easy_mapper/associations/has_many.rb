module EasyMapper
  module Associations
    class HasMany
      attr_accessor :name, :cls, :mapped_by

      def initialize(name, cls, mapped_by)
        @name = name
        @cls = cls
        @mapped_by = mapped_by
      end
    end
  end
end
