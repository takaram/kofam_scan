RSpec.describe KOHMM::HMMSearch do
  let(:obj) { described_class.new("profile", "sequences", cpu: 2, o: "out file") }

  describe '#to_a' do
    subject { obj.to_a }

    it 'returns array of command and arguments' do
      expect(subject).to match_array(%w[hmmsearch --cpu=2 -oout\ file profile sequences])
    end
  end

  describe '#to_s' do
    subject { obj.to_s }

    it 'returns command string' do
      expect(subject).to eq 'hmmsearch --cpu\=2 -oout\ file profile sequences'
    end
  end

  describe '.command_path' do
    let(:path) { "/usr/bin/hmmsearch" }

    before do
      described_class.command_path = path
    end

    it 'alternates the command' do
      expect(obj.to_a.first).to eq path
      expect(obj.to_s.split(/\s/).first).to eq path
    end
  end
end
