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
                .build

      @db_adapter.execute(query)
    end

    def update(id, record)
      values_to_update = record.reject { |key, value| key.eql? :id }.to_h

      query = @sql.update
                .table(@model.table_name)
                .where(id: id)
                .set(escape_values(values_to_update))
                .build

      @db_adapter.execute(query)
    end

    def find(query)
      sql_builder = @sql.select
                .from(@model.table_name)

      sql_builder.where(escape_values(query.where)) unless query.where.empty?
      sql_builder.order(escape_values(query.order)) unless query.order.empty?
      sql_builder.limit(escape(query.limit)) if query.limit
      sql_builder.offset(escape(query.offset)) if query.offset

      sql_query = sql_builder.build
      @db_adapter.execute(sql_query)
    end

    def next_id
      @db_adapter.next_id(@model.table_name)
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
