class Barkdog::Driver
  include Barkdog::Logger::Helper

  def initialize(dog, options = {})
    @dog = dog
    @options = options
  end

  def create_monitor(name, attrs)
    updated = false
    log(:info, "Create Monitor: #{name}", :color => :cyan)

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

  def update_monitor(name, attrs)
    updated = false
    log(:info, "Update Monitor: #{name}", :color => :green)

    attrs.each do |key, value|
      next if key == 'id'
      log(:info, " set #{key}=#{value}", :color => :green)
    end

    unless @options[:dry_run]
      @dog.update_monitor(
        attrs['id'],
        attrs['query'],
        :name => name,
        :message => attrs['message'],
        :options => attrs['options']
      )

      updated = true
    end

    updated
  end
end
