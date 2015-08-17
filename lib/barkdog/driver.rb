class Barkdog::Driver
  include Barkdog::Logger::Helper

  def initialize(dog, options = {})
    @dog = dog
    @options = options
  end

  def create_monitor(name, attrs)
    updated = false
    log(:info, "Create Monitor: #{name}", :color => :cyan)

    if @options[:ignore_silenced]
      attrs['options'].delete('silenced')
    end

    unless @options[:dry_run]
      @dog.monitor(
        attrs['type'],
        attrs['query'],
        :name => name,
        :message => attrs['message'],
        :options => attrs['options']
      )

      updated = true
    end

    updated
  end

  def delete_monitor(name, attrs)
    updated = false
    log(:info, "Delete Monitor: #{name}", :color => :red)

    unless @options[:dry_run]
      @dog.delete_monitor(attrs['id'])
      updated = true
    end

    updated
  end

  def update_monitor(name, expected, actual)
    updated = false

    if @options[:ignore_silenced]
      expected['options'].delete('silenced')
      actual['options'].delete('silenced')
    end

    diffy = Diffy::Diff.new(
      Barkdog::DSL::Converter.convert({name => actual}),
      Barkdog::DSL::Converter.convert({name => expected}),
      :diff => "-u"
    )

    if diffy.diff.size > 0
      log(:info, "Update Monitor: #{name}", :color => :cyan)
      log(:info, diffy.to_s(:color), :color => false )
      unless @options[:dry_run]
        @dog.update_monitor(
          expected['id'],
          expected['query'],
          :name => name,
          :message => expected['message'],
          :options => expected['options']
        )
        updated = true
      end
    end

    updated
  end
end
