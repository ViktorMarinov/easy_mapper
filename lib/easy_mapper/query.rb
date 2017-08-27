module EasyMapper
  class Query
    include Enumerable

    attr_accessor :model
    # builder methods

    def initialize(model)
      @model = model
      @where = {}
      @order_by = {}
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

    def order_by(fields)
      if @order_by
        @order_by.merge!(fields)
      else
        @order_by = fields
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
      @model.repository.find(@where, @order_by, @offset, @limit)
    end
  end
end
