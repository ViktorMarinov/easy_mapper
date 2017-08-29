module EasyMapper
  class Query
    include Enumerable

    attr_accessor :model


    def initialize(model)
      @model = model
      @where = {}
      @order = {}
    end

    def where(query = nil)
      return @where unless query

      if @where
        @where.merge!(query)
      else
        @where = query
      end

      self
    end

    def all
      where({})
    end

    def order(fields = nil)
      return @order unless fields

      if @order
        @order.merge!(fields)
      else
        @order = fields
      end

      self
    end

    def limit(value = nil)
      return @limit unless value

      @limit = value

      self
    end

    def offset(value = nil)
      return @offset unless value

      @offset = value

      self
    end

    # kickers

    def exec
      execute_find
    end

    def each(&block)
      execute_find.each(&block)
    end

    def count(field)
      raise NotImplementedError
    end

    def avg(field)
      raise NotImplementedError
    end

    def inspect
      execute_find.inspect
    end

    def delete_all
      @model.repository.delete({})
    end

    private

    def execute_find
      map_to_model_instances @model.repository.find(self)
    end

    def map_to_model_instances(records)
      records.map { |record| @model.new(record) }
    end
  end
end
