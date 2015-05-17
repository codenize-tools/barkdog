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
    #[
    #  output_users(@exported[:users]),
    #  output_groups(@exported[:groups]),
    #  output_roles(@exported[:roles]),
    #  output_instance_profiles(@exported[:instance_profiles]),
    #].join("\n")
  end

  private

  def output_monitors(monitor_by_name)
    monitor_by_name.sort_by {|k, v| k }.map {|monitor_name, attrs|
      next unless target_matched?(monitor_name)
      output_monitor(monitor_name, attrs)
    }.select {|i| i }.join("\n")
  end

  def output_monitor(monitor_name, attrs)
    fixed_options = Hash[%w(type multi).map {|k| [k.to_sym, attrs[k]] }]
    query = attrs['query']
    message = attrs['message']
    monitor_options = attrs['options'] || {}

    if monitor_options.empty?
      monitor_options = ''
    else
      monitor_options = "\n" + output_monitor_options(monitor_options)
    end

    <<-EOS
monitor #{monitor_name.inspect}, #{unbrace(fixed_options.inspect)} do
  query #{query.inspect}
  message #{message.inspect}#{
  monitor_options}
end
    EOS
  end

  def output_monitor_options(monitor_options)
    options_body = monitor_options.map {|key, value|
      value_is_hash = value.is_a?(Hash)
      value = value.inspect

      if value_is_hash
        value = unbrace(value).strip
        value = value.empty? ? '({})' : " #{value}"
      else
        value = " #{value}"
      end

      "#{key}#{value}"
    }.join("\n    ")

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
