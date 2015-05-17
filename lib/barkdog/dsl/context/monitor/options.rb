class Barkdog::DSL::Context::Monitor::Options
  def initialize(&block)
    @result = {}
    instance_eval(&block)
  end

  attr_reader :result

  private

  def method_missing(method_name, *args)
    if args.length == 1
      value = args.first
      @result[method_name.to_s] = value
    else
      super
    end
  end
end
