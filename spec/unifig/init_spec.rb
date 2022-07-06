RSpec.describe Unifig::Init do
  describe '.load' do
    subject(:load) { described_class.load(str, env) }

    let(:env) { :development }

    context 'with invalid YAML' do
      let(:str) { '`' }

      it 'throws an error' do
        expect { load }.to raise_error Unifig::YAMLSyntaxError
      end
    end

    context 'with an invalid alias' do
      let(:str) { 'a: *b' }

      it 'throws an error' do
        expect { load }.to raise_error Unifig::YAMLSyntaxError
      end
    end

    context 'without a config' do
      let(:str) do
        <<~YML
          FOO_BAR:
            value: "baz"
        YML
      end

      it 'throws an error' do
        expect { load }.to raise_error Unifig::MissingConfig
      end
    end

    context 'with a config' do
      let(:str) do
        <<~YML
          config:
            envs:
              development:
                providers: local

          FOO_BAR:
            value: baz
        YML
      end

      it 'loads up a string of yaml' do
        load

        expect(Unifig).to respond_to(:foo_bar)
        expect(Unifig.foo_bar).to eql 'baz'
      end

      context 'with no providers' do
        let(:str) do
          <<~YML
            config:
              envs:
                development:
                  providers:

            FOO_BAR:
              value: baz
          YML
        end

        it 'loads nothing' do
          load

          expect(Unifig).to_not respond_to(:foo_bar)
        end
      end

      context 'with an invalid provider' do
        let(:str) do
          <<~YML
            config:
              envs:
                development:
                  providers: invalid

            FOO_BAR:
              value: baz
          YML
        end

        it 'throws an error' do
          expect { load }.to raise_error Unifig::MissingProvider
        end
      end
    end

    context 'with an env override' do
      let(:str) do
        <<~YML
          config:
            envs:
              development:
                providers: local

          FOO_BAR:
            value: baz
            envs:
              development:
                value: boz
        YML
      end

      it 'loads up a string of yaml' do
        load

        expect(Unifig).to respond_to(:foo_bar)
        expect(Unifig.foo_bar).to eql 'boz'
      end
    end
  end
end
