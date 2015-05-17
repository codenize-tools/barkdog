class Barkdog::DSL::Context
  def self.eval(dsl, path, options = {})
    self.new(path, options) {
      eval(dsl, binding, path)
    }
  end

  attr_reader :result

  def initialize(path, options = {}, &block)
    @path = path
    @options = options
    @result = {}
    instance_eval(&block)
  end

  private

  def require(file)
    barkfile = (file =~ %r|\A/|) ? file : File.expand_path(File.join(File.dirname(@path), file))

    if File.exist?(barkfile)
      instance_eval(File.read(barkfile), barkfile)
    elsif File.exist?(barkfile + '.rb')
      instance_eval(File.read(barkfile + '.rb'), barkfile + '.rb')
    else
      Kernel.require(file)
    end
  end

  def monitor(name, fixed_options = {}, &block)
    name = name.to_s

    if @result[name]
      raise "Monitor `#{name}` is already defined"
    end

    fixed_options = Hash[fixed_options.map {|k, v| [k.to_s, v] }]
    attrs = Barkdog::DSL::Context::Monitor.new(name, &block).result
    @result[name] = fixed_options.merge(attrs)
  end
end
