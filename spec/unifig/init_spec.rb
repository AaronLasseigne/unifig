RSpec.describe Unifig::Init do
  describe '.load' do
    subject(:load) { described_class.load(str) }

    context 'with valid YAML' do
      let(:str) do
        <<~YML
          FOO_BAR:
            value: "baz"
        YML
      end

      it 'loads up a string of yaml' do
        load

        expect(Unifig).to respond_to(:foo_bar)
        expect(Unifig.foo_bar).to eql 'baz'
      end
    end

    context 'with invalid YAML' do
      let(:str) { '`' }

      it 'throws an error' do
        expect { load }.to raise_error Unifig::YAMLSyntaxError
      end
    end
  end

  describe '#exec!' do
    subject(:init) { described_class.new(yml) }

    let(:yml) { {} }

    context 'with valid symbolized yaml' do
      let(:yml) { { FOO_BAR: { value: 'baz' } } }

      before do
        init.exec!
      end

      it 'adds a getter to Unifig' do
        expect(Unifig).to respond_to(:foo_bar)
        expect(Unifig.foo_bar).to eql 'baz'
      end
    end
  end
end
