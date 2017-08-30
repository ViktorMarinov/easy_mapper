module EasyMapper
  module Adapters
    class PostgreResult
      def initialize(result)
        @result = result
      end

      def single_hash
        list.first
      end

      def single_value
        @result.values.first.first
      end

      def values
        @result.values
      end

      def list
        @result.map do |row|
          row.map { |key, value| [key.to_sym, value] }.to_h
        end
      end
    end
  end
end
