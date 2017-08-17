module EasyMapper
  module Model
    module QueryMethods
      def objects
        Query.new(self)
      end
    end
  end
end

