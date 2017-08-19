require_relative 'config'

module EasyMapper
  class Repository
    attr_reader :adapter, :model

    def initialize(model)
      @model = model
      @adapter = EasyMapper::Config.adapter
    end

    def upsert(record)
      @adapter.upsert(@model, record, @model.primary_keys)
    end

    def create(record)
      @adapter.insert(@model, record)
    end

    def find(query)
      result_set = @adapter.find(@model, query)
      #TODO: map to instances
    end

    def delete(query)
      @adapter.delete(@model, query)
    end

    def update(query, kv_map)
      @adapter.update(@model, kv_map)
    end
  end
end
