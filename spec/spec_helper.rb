require 'barkdog'
require 'tempfile'

BARKDOG_TEST_API_KEY = ENV['BARKDOG_TEST_API_KEY']
BARKDOG_TEST_APP_KEY = ENV['BARKDOG_TEST_APP_KEY']

RSpec.configure do |config|
  config.before(:each) do
    barkdog { '' }
  end

  config.after(:all) do
    barkdog { '' }
  end
end

def barkdog_client(options = {})
  options = {
    api_key: BARKDOG_TEST_API_KEY,
    application_key: BARKDOG_TEST_APP_KEY,
  }.merge(options)

  if ENV['DEBUG'] == '1'
    options[:debug] = true
  else
    options[:logger] = Logger.new('/dev/null')
  end

  Barkdog::Client.new(options)
end

def barkdog(options = {})
  client = barkdog_client(options)

  tempfile(yield) do |f|
    client.apply(f.path)
  end
end

def tempfile(content, options = {})
  basename = "#{File.basename __FILE__}.#{$$}"
  basename = [basename, options[:ext]] if options[:ext]

  Tempfile.open(basename) do |f|
    f.puts(content)
    f.flush
    f.rewind
    yield(f)
  end
end
