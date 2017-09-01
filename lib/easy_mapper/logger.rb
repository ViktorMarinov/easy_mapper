require 'logger'

module EasyMapper
  class Logger
    class << self
      attr_writer :device, :level

      device = STDOUT
      level = :DEBUG

      def logger
        unless @logger
          @logger = ::Logger.new device
          @logger.level = ::Logger.const_get(level)
          @logger.datetime_format = '%Y-%m-%d %H:%M:%S '
        end

        @logger
      end

      private

      def device
        @device = STDOUT unless @device

        @device
      end

      def level
        @level = :DEBUG unless @level

        @level
      end
    end
  end
end
