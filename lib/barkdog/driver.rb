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

    tags = attrs['tags'] || []

    unless @options[:dry_run]
      _, response = @dog.monitor(
        attrs['type'],
        attrs['query'],
        :name => name,
        :message => attrs['message'],
        :options => attrs['options'],
        :tags => tags
      )

      validate_response(response)
      updated = true
    end

    updated
  end

  def delete_monitor(name, attrs)
    return false if @options[:no_delete]

    updated = false
    log(:info, "Delete Monitor: #{name}", :color => :red)

    unless @options[:dry_run]
      _, response = @dog.delete_monitor(attrs['id'])
      validate_response(response)
      updated = true
    end

    updated
  end

  def update_monitor(name, expected, actual)
    updated = false

    if @options[:ignore_silenced]
      expected['options'].delete('silenced') if expected['options']
      actual['options'].delete('silenced') if actual['options']
    end

    diffy = Diffy::Diff.new(
      Barkdog::DSL::Converter.convert({name => actual}),
      Barkdog::DSL::Converter.convert({name => expected}),
      :diff => "-u"
    )

    if diffy.diff.size > 0
      log(:info, "Update Monitor: #{name}", :color => :cyan)
      log(:info, diffy.to_s(@options[:color] ? :color : :text), :color => false)

      unless @options[:dry_run]
        _, response = @dog.update_monitor(
          expected['id'],
          expected['query'],
          :name => name,
          :message => expected['message'],
          :options => expected['options'],
          :tags => expected['tags']
        )

        validate_response(response)
        updated = true
      end
    end

    updated
  end

  private

  def validate_response(response)
    if response['warnings']
      log(:warn, response['warnings'].join("\n"), :color => :yellow)
    end

    if response['errors']
      raise response['errors'].join("\n")
    end
  end
end
