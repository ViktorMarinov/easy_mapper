require_relative 'config'

module EasyMapper
  class Repository
    attr_reader :adapter, :model

    def initialize(model)
      @model = model
      @adapter = EasyMapper::Config.adapter
    end

    def upsert(record)
      @adapter.upsert(table_name(@model), record, primary_keys: @model.primary_keys)
    end

    def create(record)
      @adapter.insert(table_name(@model), record)
    end

    def find(query)
      result_set = @adapter.find(table_name(@model), query)
      # TODO: map to instances
    end

    def delete(query)
      @adapter.delete(table_name(@model), query)
    end

    def update(_query, kv_map)
      @adapter.update(table_name(@model), kv_map)
    end

    private

    def table_name(clazz)
      clazz.table_name || generate_name(clazz)
    end

    def generate_name(clazz)
      raise Errors::AnonymousClassError unless clazz.name

      if clazz.name[-1] == 's'
        "#{clazz}es"
      else
        "#{clazz}s"
      end
    end
  end
end
