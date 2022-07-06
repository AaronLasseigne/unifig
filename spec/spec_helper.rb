require 'unifig'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.on_potential_false_positives = :nothing
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.filter_run_when_matching :focus

  config.example_status_persistence_file_path = 'spec/examples.txt'

  config.disable_monkey_patching!

  config.warnings = true

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.order = :random
  Kernel.srand config.seed

  # clear Unifg methods
  config.before do
    Unifig.methods(false).each do |name|
      Unifig.singleton_class.remove_method(name)
    end
  end

  # Add a fake Provider for testing
  config.before(:suite) do
    module Unifig # rubocop:disable Lint/ConstantDefinitionInBlock
      module Providers
        module FortyTwo
          def self.name
            :forty_two
          end

          def self.retrieve(var_names)
            var_names.to_h do |var_name|
              [var_name, 42]
            end
          end
        end
      end
    end
  end
  config.after(:suite) do
    Unifig::Providers.send(:remove_const, :FortyTwo)
  end
end
