class MockRepository
  attr_reader :storage

  def initialize
    @storage = []
  end

  def create(record)
    @storage << record
  end

  def find(query)
    @storage.select { |record| match_record? query, record }
  end

  def delete(query)
    @storage.reject! { |record| match_record? query, record }
  end

  def update(query, kv_map)
    find(query).each do |entry|
      kv_map.each do |key, value|
        if entry.respond_to? "#{key}=" do
          entry.send("#{key}=", value)
        end
      end
    end
  end

  private

  def match_record?(query, record)
    query.all? { |key, value| record[key] == value }
  end
end
