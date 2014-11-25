GemRoot = File.join(File.dirname(__FILE__), '../')

# Load up all fixture definitions
Dir[File.join(GemRoot, 'spec', 'fixtures', '**', '*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.raise_errors_for_deprecations!
  config.order = 'random' # specify seed with --seed XXXX
end
