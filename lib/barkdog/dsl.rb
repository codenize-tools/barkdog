class Barkdog::DSL
  def self.convert(exported, options = {})
    Barkdog::DSL::Converter.convert(exported, options)
  end

  def self.parse(dsl, path, options = {})
    Barkdog::DSL::Context.eval(dsl, path, options).result
  end
end
