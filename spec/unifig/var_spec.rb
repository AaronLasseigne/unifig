RSpec.describe Unifig::Var do
  subject(:var) { described_class.new(name, config) }

  let(:name) { :NAME }
  let(:config) { {} }

  describe '#method' do
    let(:name) { :'A-B' }

    it 'lowercases and switches dashes to underscores' do
      expect(var.method).to be :a_b
    end
  end
end
