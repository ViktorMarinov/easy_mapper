require_relative 'config'

require 'sqlbuilder'

module EasyMapper
  class DbRepository
    def initialize(model, db_adapter)
      @model = model
      @db_adapter = db_adapter
      @sql = db_adapter.sql_builder

      @db_adapter.connect
    end

    def create(record)
      query = @sql.insert
                .into(@model.table_name)
                .record(escape_values(record))
                .build

      @db_adapter.execute(query)
    end

    def delete(query_filters)
      query = @sql.delete
                .from(@model.table_name)
                .where(escape_values(query_filters))

      @db_adapter.execute(query)
    end

    def find(query)
      sql_query = @sql.select
                .from(@model.table_name)

      sql_query.where(escape_values(query.where)) unless query.where.empty?
      sql_query.order(escape_values(query.order)) unless query.order.empty?
      sql_query.limit(escape(query.limit)) if query.limit
      sql_query.offset(escape(query.offset)) if query.offset

      @db_adapter.execute(sql_query)
    end

    def next_id
      seq_name = "#{@model.table_name}_id_seq"

      query = @sql.sequence(name).create_unless_exists
      @db_adapter.execute(query)

      query = @sql.sequence(seq_name).next_val
      @db_adapter.execute(seq_name)
    end

    private

    def escape(value)
      @db_adapter.escape(value)
    end

    def escape_values(record)
      kv_list = record.map do |key, value|
        [key, escape(value)]
      end

      kv_list.to_h
    end
  end
end
