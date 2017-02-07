class Barkdog::DSL::Context::Monitor
  include Barkdog::TemplateHelper

  def initialize(context, name, &block)
    @monitor_name = name
    @context = context.merge(:monitor_name => name)
    @result = {}
    instance_eval(&block)
  end

  attr_reader :result

  private

  def query(value)
    @result['query'] = value.to_s
  end

  def message(value)
    @result['message'] = value.to_s
  end

  def tags(value)
    @result['tags'] = value.to_a
  end

  def options(&block)
    @result['options'] = Barkdog::DSL::Context::Monitor::Options.new(@context, &block).result
  end
end
