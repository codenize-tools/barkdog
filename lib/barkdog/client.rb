class Barkdog::Client
  def initialize(options = {})
    @options = options

    api_key, app_key = @options.values_at(:api_key, :application_key)
    raise 'API Key does not exist' unless api_key
    raise 'Application Key does not exist' unless app_key

    @dog = Dogapi::Client.new(api_key, app_key)
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

    # XXX:
    [expected, actual]
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
