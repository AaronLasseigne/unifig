RSpec.describe Unifig::Config do
  subject(:config) { described_class.new(config_hash, env: env) }

  let(:env) { nil }
  let(:config_hash) do
    {
      providers: 'local',
      envs: {
        development: {
          providers: %w[local forty_two]
        }
      }
    }
  end

  describe '#new' do
    context 'without a config' do
      let(:config_hash) { nil }

      it 'raises an error' do
        expect { config }.to raise_error Unifig::MissingConfigError
      end
    end
  end

  describe '#providers' do
    it 'returns a list of providers' do
      expect(config.providers).to eql %i[local]
    end

    context 'with an :env' do
      let(:env) { :development }

      it 'returns the list of providers for that env' do
        expect(config.providers).to eql %i[local forty_two]
      end
    end

    context 'with a :list' do
      let(:config_hash) do
        {
          providers: {
            list: 'local'
          }
        }
      end

      it 'returns a list of providers' do
        expect(config.providers).to eql %i[local]
      end
    end
  end
end
