class Barkdog::DSL::Context::Monitor
  def initialize(name, &block)
    @monitor_name = name
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

  def options(&block)
    @result['options'] = Barkdog::DSL::Context::Monitor::Options.new(&block).result
  end
end
