RSpec.describe Unifig::Config do
  subject(:config) { described_class.new(config_hash, env) }

  let(:env) { :development }
  let(:env_config) do
    {
      providers: 'local'
    }
  end
  let(:config_hash) do
    {
      envs: {
        "#{env}": env_config
      }
    }
  end

  describe '#env' do
    it 'returns the env config' do
      expect(config.env).to eql env_config
    end
  end

  describe '#providers' do
    it 'returns a list of providers for the selected env' do
      expect(config.providers).to eql %i[local]
    end
  end
end
