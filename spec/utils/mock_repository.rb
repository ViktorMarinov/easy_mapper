class MockRepository
  attr_reader :storage

  def initialize
    @storage = {}
    @id_counter = 0
  end

  def next_id
    @id_counter += 1
  end

  def create(record)
    @storage[record[:id]] = record
  end

  def find(query)
    @storage.values.select do |record|
      query.where.all? { |key, value| record[key] == value }
    end
  end

  def delete(query)
    records = @storage.values.select do |record|
      query.all? { |key, value| record[key] == value }
    end

    records.each { |record| @storage.delete(record[:id]) }
  end

  def update(id, record)
    return unless @storage.key? id
    @storage[id] = record
  end
end
