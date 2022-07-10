require 'tempfile'

RSpec.shared_examples 'basic load tests' do
  context 'with invalid YAML' do
    let(:str) { '`' }

    it 'throws an error' do
      expect { subject }.to raise_error Unifig::YAMLSyntaxError
    end
  end

  context 'with an invalid alias' do
    let(:str) { 'a: *b' }

    it 'throws an error' do
      expect { subject }.to raise_error Unifig::YAMLSyntaxError
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
      expect { subject }.to raise_error Unifig::MissingConfig
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
      subject

      expect(Unifig).to respond_to(:foo_bar)
      expect(Unifig.foo_bar).to eql 'baz'
    end
  end
end

RSpec.describe Unifig::Init do
  let(:env) { :development }

  describe '.load' do
    subject(:load) { described_class.load(str, env) }

    include_examples 'basic load tests'

    context 'from multiple providers' do
      let(:str) do
        <<~YML
          config:
            envs:
              development:
                providers: [local, forty_two]

          FOO:
          BAR:
            value: bar
        YML
      end

      it 'returns the values from the providers in order' do
        load

        expect(Unifig.foo).to be 42
        expect(Unifig.bar).to eql 'bar'
      end
    end

    context 'with an optional var' do
      before { load }

      context 'that is available' do
        let(:str) do
          <<~YML
            config:
              envs:
                development:
                  providers: local

            FOO_BAR:
              optional: true
              value: baz
          YML
        end

        it 'loads the var' do
          expect(Unifig.foo_bar).to eql 'baz'
        end

        it 'sets the predicate to true' do
          expect(Unifig).to be_foo_bar
        end
      end

      context 'that is not available' do
        let(:str) do
          <<~YML
            config:
              envs:
                development:
                  providers: local

            FOO_BAR:
              optional: true
          YML
        end

        it 'makes the var nil' do
          expect(Unifig.foo_bar).to be_nil
        end

        it 'sets the predicate to false' do
          expect(Unifig).to_not be_foo_bar
        end
      end

      context 'that is not blank' do
        let(:str) do
          <<~YML
            config:
              envs:
                development:
                  providers: local

            FOO_BAR:
              optional: true
              value: ' '
          YML
        end

        it 'makes the var nil' do
          expect(Unifig.foo_bar).to be_nil
        end

        it 'sets the predicate to false' do
          expect(Unifig).to_not be_foo_bar
        end
      end
    end

    context 'with a required var' do
      context 'that is available' do
        before { load }

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

        it 'loads the var' do
          expect(Unifig.foo_bar).to eql 'baz'
        end

        it 'sets the predicate to true' do
          expect(Unifig).to be_foo_bar
        end
      end

      context 'that is not available' do
        let(:str) do
          <<~YML
            config:
              envs:
                development:
                  providers: local

            FOO_BAR:
              value:
          YML
        end

        it 'throws an error' do
          expect { load }.to raise_error Unifig::MissingRequired
        end
      end

      context 'that is blank' do
        let(:str) do
          <<~YML
            config:
              envs:
                development:
                  providers: local

            FOO_BAR:
              value: ' '
          YML
        end

        it 'throws an error' do
          expect { load }.to raise_error Unifig::MissingRequired
        end
      end
    end
  end

  describe '.load_file' do
    subject(:load_file) { described_class.load_file(file_path, env) }

    let(:file) do
      Tempfile.new(%w[test .yml]).tap do |file|
        file.write(str)
        file.close
      end
    end
    let(:file_path) { file.path }

    include_examples 'basic load tests'
  end
end
