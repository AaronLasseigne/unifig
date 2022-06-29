RSpec.describe Unifig::Init do
  subject(:init) { described_class.new(yml) }

  let(:yml) { {} }

  describe '#exec!' do
    context 'with valid YML' do
      let(:yml) { { 'FOO_BAR' => { 'value' => 'baz' } } }

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
