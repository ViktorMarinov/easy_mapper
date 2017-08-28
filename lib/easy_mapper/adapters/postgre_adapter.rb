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
        puts "Executing query: #{query}"
        @connection.exec(query)
      end

      def escape(value)
        PG::Connection.escape_string(value)
      end

      def sql_builder
        Sqlbuilder::Builders::PostgresBuilder.new
      end
    end
  end
end
