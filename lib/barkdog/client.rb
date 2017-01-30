class Barkdog::Client
  include Barkdog::Logger::Helper

  def initialize(options = {})
    @options = options

    api_key, app_key = @options.values_at(:api_key, :application_key)
    raise 'API Key does not exist' unless api_key
    raise 'Application Key does not exist' unless app_key

    # api_key, application_key=nil, host=nil, device=nil, silent=true, timeout=nil
    # We force silent to false so any exceptions get propated back out and we fail loudly.
    @dog = Dogapi::Client.new(api_key, app_key, nil, nil, false, @options[:datadog_timeout])
    @driver = Barkdog::Driver.new(@dog, @options)
  end

  def export(export_options = {})
    exported = Barkdog::Exporter.export(@dog, @options)
    Barkdog::DSL.convert(exported, @options)
  end

  def apply(file)
    walk(file)
  end

  private

  def walk(file)
    expected = load_file(file)
    actual = Barkdog::Exporter.export(@dog, @options)
    if actual.empty? && @options[:fail_if_empty]
      raise 'Zero existing monitors reported, failing as --fail-if-empty is set'
    end
    walk_monitors(expected, actual)
  end

  def walk_monitors(expected, actual)
    updated = false

    expected.each do |name, expected_monitor|
      actual_monitor = actual.delete(name)

      if actual_monitor
        updated = walk_monitor(name, expected_monitor, actual_monitor) || updated
      else
        updated = @driver.create_monitor(name, expected_monitor) || updated
      end
    end

    actual.each do |name, actual_monitor|
      updated = @driver.delete_monitor(name, actual_monitor) || updated
    end

    updated
  end

  def walk_monitor(name, expected, actual)
    updated = false

    Barkdog::FIXED_OPTION_KEYS.each do |key|
      if expected[key] != actual[key]
        log(:warn, "#{name}: `#{key}` can not be changed (Changes has been ignored)", :color => :yellow)
        return updated
      end
    end

    actual_without_id = actual.dup
    monitor_id = actual_without_id.delete('id')

    if expected != actual_without_id
      updated = @driver.update_monitor(name, expected.merge('id' => monitor_id), actual) || updated
    end

    updated
  end

  def load_file(file)
    if file.kind_of?(String)
      open(file) do |f|
        Barkdog::DSL.parse(f.read, file)
      end
    elsif [File, Tempfile].any? {|i| file.kind_of?(i) }
      Barkdog::DSL.parse(file.read, file.path)
    else
      raise TypeError, "can't convert #{file} into File"
    end
  end
end
