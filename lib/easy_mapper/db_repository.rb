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
                .record(record)
                .build

      @db_adapter.execute(query)
    end

    def delete(query_filters)
      query = @sql.delete
                .from(@model.table_name)
                .where(query_filters)
                .build

      @db_adapter.execute(query)
    end

    def update(id, record)
      values_to_update = record.reject { |key, value| key.eql? :id }.to_h

      query = @sql.update
                .table(@model.table_name)
                .where(id: id)
                .set(values_to_update)
                .build

      @db_adapter.execute(query)
    end

    def find(query)
      sql_builder = @sql.select
                .column('*', from: 'model')
                .from(@model.table_name, aliaz: 'model')

      build_join(sql_builder)

      sql_builder.where(query.where) unless query.where.empty?
      sql_builder.order(query.order) unless query.order.empty?
      sql_builder.limit(query.limit) if query.limit
      sql_builder.offset(query.offset) if query.offset

      sql_query = sql_builder.build
      @db_adapter.execute(sql_query).list
    end

    def next_id
      @db_adapter.next_id(@model.table_name)
    end

    def aggregate(aggregation, field, where_clause)
      sql_builder = @sql.select
                      .from(@model.table_name)
                      .aggregation(aggregation, field)

      sql_builder.where(where_clause) unless where_clause.empty?

      sql_query = sql_builder.build
      @db_adapter.execute(sql_query).single_value
    end

    private

    def build_join(sql_builder)
      @model.associations_to_one.each do |assoc|
        column = assoc.id_column.to_sym

        assoc.cls.attributes.each do |attr|
          sql_builder.column(
            attr.to_s,
            from: "#{assoc.name}",
            as: "#{assoc.name}.#{attr}"
          )
        end

        sql_builder.join(assoc.cls.table_name, on: {column => :id})
      end
    end
  end
end
