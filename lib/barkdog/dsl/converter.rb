class Barkdog::DSL::Converter
  def self.convert(exported, options = {})
    self.new(exported, options).convert
  end

  def initialize(exported, options = {})
    @exported = exported
    @options = options
  end

  def convert
    output_monitors(@exported)
  end

  private

  def output_monitors(monitor_by_name)
    monitor_by_name.sort_by {|k, v| k }.map {|monitor_name, attrs|
      next unless target_matched?(monitor_name)
      output_monitor(monitor_name, attrs)
    }.select {|i| i }.join("\n")
  end

  def output_monitor(monitor_name, attrs)
    fixed_options = Hash[Barkdog::FIXED_OPTION_KEYS.map {|k| [k.to_sym, attrs[k]] }]
    query = attrs['query']
    message = attrs['message']
    tags = attrs['tags'] || []
    monitor_options = attrs['options'] || {}

    if monitor_options.empty?
      monitor_options = ''
    else
      monitor_options = "\n" + output_monitor_options(monitor_options)
    end

    if tags.empty?
      tags_output = ''
    else
      tags_output = "\n  tags #{tags.inspect}"
    end

    <<-EOS
monitor #{monitor_name.inspect}, #{unbrace(fixed_options.inspect)} do
  query #{query.inspect}
  message #{message.inspect}#{
  tags_output}#{
  monitor_options}
end
    EOS
  end

  def output_monitor_options(monitor_options)
    options_body = monitor_options.map {|key, value|
      value_is_hash = value.is_a?(Hash)

      if value_is_hash
        value = value.map{ |k,v| "#{k.inspect}=>#{v.inspect}" }.sort.join(", ")
        value = value.empty? ? '({})' : " #{value}"
      else
        value = " #{value.inspect}"
      end

      "#{key}#{value}"
    }.sort.join("\n    ")

    <<-RUBY.chomp
  options do
    #{options_body}
  end
    RUBY
  end

  def unbrace(str)
    str.sub(/\A\s*\{/, '').sub(/\}\s*\z/, '').strip
  end

  def target_matched?(name)
    if @options[:target]
      name =~ @options[:target]
    else
      true
    end
  end
end
