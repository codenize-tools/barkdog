class Barkdog::Exporter
  EXCLUDE_KEYS = %w(
    overall_state
    creator
    org_id
    multi
  )

  class << self
    def export(dog, opts = {})
      self.new(dog, opts).export
    end
  end # of class methods

  def initialize(dog, options = {})
    @dog = dog
    @options = options
  end

  def export
    monitors = @dog.get_all_monitors[1]
    normalize(monitors)
  end

  private

  def normalize(monitors)
    monitor_by_name = {}

    monitors.each do |m|
      name = m.delete('name')

      if monitor_by_name[name]
        raise "Duplicate monitor name exists: #{name}"
      end

      EXCLUDE_KEYS.each do |key|
        m.delete(key)
      end

      if @options[:ignore_silenced]
        m['options'].delete('silenced')
      end

      monitor_by_name[name] = m
    end

    monitor_by_name
  end
end

