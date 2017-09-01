require 'pg'
require 'sqlbuilder'

require_relative 'results/postgre_result'
require_relative '../logger'

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

        @connection.set_notice_processor do |warning|
          Logger.logger.warn(warning)
        end

        @connection.type_map_for_results =
          PG::BasicTypeMapForResults.new(@connection)
      end

      def execute(query)
        Logger.logger.info("Executing query: #{query}")
        PostgreResult.new @connection.exec(query)
      end

      def sql_builder
        Sqlbuilder::Builders::PostgresBuilder.new
      end

      def next_id(table_name)
        seq_name = "#{table_name}_id_seq"

        execute(sql_builder.sequence(seq_name).create_unless_exists)

        query = sql_builder.sequence(seq_name).next_val
        execute(query).single_value
      end
    end
  end
end
