require_relative 'db_repository'

module EasyMapper
  module Config
    class << self
      attr_accessor :db_adapter
    end
  end
end
