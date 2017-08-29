require 'pg'
require 'sqlbuilder'

module EasyMapper
  module Adapters
    class PostgreAdapter
      def initialize(
          host: '127.0.0.1',
          port: 5432,
          database:,
          user:,
          password:
        )

        @connection_options = {
          host: host,
          port: port,
          dbname: database,
          user: user,
          password: password
        }
      end

      def connect
        @connection = PGconn.connect(@connection_options)

        @connection.type_map_for_results =
          PG::BasicTypeMapForResults.new(@connection)
      end

      def execute(query)
        map_result @connection.exec(query)
      end

      def escape(value)
        if value.kind_of? String
          PG::Connection.escape_string(value)
        else
          value
        end
      end

      def sql_builder
        Sqlbuilder::Builders::PostgresBuilder.new
      end

      def next_id(table_name)
        seq_name = "#{table_name}_id_seq"

        execute(sql_builder.sequence(seq_name).create_unless_exists)

        query = sql_builder.sequence(seq_name).next_val
        execute(query)[0][:nextval]
      end

      private

      def map_result(result)
        result.map do |row|
          row.map { |key, value| [key.to_sym, value] }.to_h
        end
      end
    end
  end
end
