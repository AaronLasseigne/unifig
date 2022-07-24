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

  describe '#providers' do
    it 'returns a list of providers for the selected env' do
      expect(config.providers).to eql %i[local]
    end

    context 'with an :env' do
      let(:env) { :development }

      it 'returns the list of providers for that env' do
        expect(config.providers).to eql %i[local forty_two]
      end
    end
  end
end
