RSpec.describe Unifig::Var do
  subject(:var) { described_class.new(name, config, env) }

  let(:name) { :NAME }
  let(:config) { {} }
  let(:env) { :development }

  describe '#method' do
    let(:name) { :'A-B' }

    it 'lowercases and switches dashes to underscores' do
      expect(var.method).to be :a_b
    end
  end

  describe '#value=' do
    it 'writes the value' do
      var.value = 'a'

      expect(var.value).to eql 'a'
    end

    it 'write blank strings as nil' do
      var.value = '   '

      expect(var.value).to be_nil
    end

    it 'freezes the value if no frozen' do
      var.value = 'a'

      expect(var.value).to eql 'a'
      expect(var.value).to be_frozen
    end
  end

  describe '#local_value' do
    context 'with no value' do
      it 'returns nil' do
        expect(var.local_value).to be_nil
      end
    end

    context 'with a top level value' do
      let(:value) { 'value' }
      let(:config) do
        {
          value: value
        }
      end

      it 'returns the value' do
        expect(var.local_value).to eql value
      end

      context 'with an override' do
        let(:config) do
          {
            value: "#{value}-1",
            envs: {
              env => {
                value: value
              }
            }
          }
        end

        it 'returns the override' do
          expect(var.local_value).to eql value
        end
      end
    end
  end

  describe '#required?' do
    context 'with no value' do
      it 'returns true' do
        expect(var).to be_required
      end
    end

    context 'with a top level value' do
      let(:value) { 'value' }
      let(:config) do
        {
          optional: true
        }
      end

      it 'returns the value' do
        expect(var).to_not be_required
      end

      context 'with an override' do
        let(:config) do
          {
            optional: false,
            envs: {
              env => {
                optional: true
              }
            }
          }
        end

        it 'returns the override' do
          expect(var).to_not be_required
        end
      end
    end
  end
end
