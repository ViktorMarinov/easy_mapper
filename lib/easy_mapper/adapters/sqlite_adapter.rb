require 'sqlite3'
require 'sqlbuilder'

require_relative 'results/sqlite_result'
require_relative '../logger'

module EasyMapper
  module Adapters
    class SqliteAdapter
      def initialize(
          host: nil,
          port: nil,
          database:,
          user: nil,
          password: nil
      )

        @database = database
      end

      def connect
        @db = SQLite3::Database.new @database
        @db.results_as_hash = true
      end

      def execute(query)
        Logger.logger.info("Executing query: #{query}")
        Results::SqliteResult.new @db.execute(query)
      end

      def sql_builder
        Sqlbuilder::Builders::PostgresBuilder.new
      end

      def next_id(table_name)
        query = sql_builder.select
                           .column('seq')
                           .from('sqlite_sequence')
                           .where(name: table_name)
                           .build

        execute(query).single_value + 1
      end
    end
  end
end
