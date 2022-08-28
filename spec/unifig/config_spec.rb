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

  describe '#provider_config' do
    it 'returns an empty config if none is provided' do
      expect(config.provider_config(:local)).to eql({})
    end

    context 'with a configuration' do
      let(:local_config) do
        {
          here: true
        }
      end
      let(:config_hash) do
        {
          providers: {
            list: 'local',
            config: {
              local: local_config
            }
          }
        }
      end

      it 'returns the config info' do
        expect(config.provider_config(:local)).to eql(local_config)
      end
    end
  end
end
