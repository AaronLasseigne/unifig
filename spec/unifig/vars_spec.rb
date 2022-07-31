RSpec.describe Unifig::Vars do
  let(:yml) do
    {
      one: {
        value: 1
      },
      two: {
        value: 2
      }
    }
  end
  let(:env) { :development }
  let(:results) { { one: 1, two: 2 } }

  before do
    described_class.load!(yml, env)
    described_class.write_results!(results, :local)
  end

  describe '.list' do
    it 'returns all of the vars' do
      vars = described_class.list

      expect(vars.size).to be 2
      vars.each.with_index(1) do |var, value|
        expect(var).to be_an_instance_of Unifig::Var
        expect(var.value).to be value
        expect(var.provider).to be :local
      end
    end
  end

  describe '.[]' do
    it 'returns the Var based on the name' do
      var = described_class[:one]

      expect(var).to be_an_instance_of Unifig::Var
      expect(var.value).to be 1
    end
  end
end
