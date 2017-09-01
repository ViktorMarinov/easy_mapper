module EasyMapper
  module Adapters
    module Results
      class SqliteResult
        def initialize(result)
          @result = result
        end

        def single_hash
          list.first
        end

        def single_value
          values.first.first
        end

        def values
          @result.map(&:values)
        end

        def list
          @result.map do |row|
            row.map do |key, value|
              key = key.to_sym if key.is_a? String

              [key, value]
            end.to_h
          end
        end
      end
    end
  end
end
