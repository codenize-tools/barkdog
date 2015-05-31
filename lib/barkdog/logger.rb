class Barkdog::Logger < ::Logger
  include Singleton

  def initialize
    super($stdout)

    self.formatter = proc do |severity, datetime, progname, msg|
      "#{msg}\n"
    end

    self.level = INFO
  end

  def set_debug(value)
    self.level = value ? DEBUG : INFO
  end

  module Helper
    def log(level, message, opts = {})
      opts = (@options || {}).merge(opts)

      message = "[#{level.to_s.upcase}] #{message}" unless level == :info
      message << ' (dry-run)' if opts[:dry_run]
      message = message.send(opts[:color]) if opts[:color]

      logger = opts[:logger] || Barkdog::Logger.instance
      logger.send(level, message)
    end
  end
end
