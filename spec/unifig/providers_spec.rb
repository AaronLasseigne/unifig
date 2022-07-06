RSpec.describe Unifig::Providers do
  describe '.all' do
    it 'returns all of the provider modules' do
      all = described_class.all

      expect(all.size).to be 2
      expect(all).to include Unifig::Providers::Local
      expect(all).to include Unifig::Providers::FortyTwo
    end
  end

  describe '.list' do
    it 'returns all providers' do
      list = described_class.list

      expect(list.size).to be 2
      expect(list).to include Unifig::Providers::Local
      expect(list).to include Unifig::Providers::FortyTwo
    end

    it 'can return a limited list' do
      list = described_class.list([Unifig::Providers::Local.name])

      expect(list.size).to be 1
      expect(list).to include Unifig::Providers::Local
    end

    it 'returns them in the order requested' do
      list = described_class.list([Unifig::Providers::Local.name, Unifig::Providers::FortyTwo.name])
      expect(list).to eql [Unifig::Providers::Local, Unifig::Providers::FortyTwo]

      list = described_class.list([Unifig::Providers::FortyTwo.name, Unifig::Providers::Local.name])
      expect(list).to eql [Unifig::Providers::FortyTwo, Unifig::Providers::Local]
    end
  end
end
