module EasyMapper
  class Query
    include Enumerable

    attr_accessor :model

    """
    builder methods
    """

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


    """
    kickers
    """

    def exec
      map_to_model_instances @model.repository.find(self)
    end

    def single_result
      #TODO: return single result, raise exception if none or more
      exec.first
    end

    def each(&block)
      exec.each(&block)
    end

    def count(field = '*')
      @model.repository.aggregate("COUNT", field, @where)
    end

    def avg(field)
       @model.repository.aggregate("AVG", field, @where).to_f
    end

    def sum(field)
      @model.repository.aggregate("SUM", field, @where)
    end

    def inspect
      exec.inspect
    end

    def delete_all
      @model.repository.delete({})
    end

    private

    def map_to_model_instances(records)
      records.map do |record|
        associations = map_associations_to_many(record)
                        .merge(map_associations_to_one(record))

        @model.new(record.merge(associations))
      end
    end

    def map_associations_to_many(record)
      @model.associations_to_many.map do |assoc_to_many|
        [
          assoc_to_many.name,
          assoc_to_many.cls.objects.where(assoc_to_many.mapped_by => record[:id])
        ]
      end.to_h
    end

    def map_associations_to_one(record)
      @model.associations_to_one.map do |assoc|
        assoc_record = record
          .select { |key, _| key.to_s.include? "#{assoc.name}_" }
          .map { |k, v| [k.to_s.gsub("#{assoc.name}_", "").to_sym, v] }
          .to_h
        [
          assoc.name,
          assoc.cls.new(assoc_record)
        ]
      end.to_h
    end
  end
end
