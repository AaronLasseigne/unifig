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
