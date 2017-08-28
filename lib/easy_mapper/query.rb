module EasyMapper
  class Query
    include Enumerable

    attr_accessor :model, :where, :limit, :offset, :order
    # builder methods

    def initialize(model)
      @model = model
      @where = {}
      @order = {}
    end

    def where(query)
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

    def order(fields)
      if @order
        @order.merge!(fields)
      else
        @order = fields
      end

      self
    end

    def limit(value)
      @limit = value

      self
    end

    def offset(value)
      @offset = value

      self
    end

    # kickers

    def each(&block)
      execute_find.each(&block)
    end

    def count(field)
      @model.repository.count(field)
    end

    def inspect
      execute_find.inspect
    end

    private

    def execute_find
      @model.repository.find(@where, @order, @offset, @limit)
    end
  end
end
