RSpec.describe KofamScan::HMMSearch do
  let(:obj) { described_class.new("profile", "sequences", cpu: 2, o: "out file") }

  describe '#to_a' do
    subject(:command_array) { obj.to_a }

    it 'returns array of command and arguments' do
      expect(command_array).to match_array(%w[hmmsearch --cpu=2 -oout\ file profile sequences])
    end
  end

  describe '#to_s' do
    subject(:command_string) { obj.to_s }

    it 'returns command string' do
      expect(command_string).to eq 'hmmsearch --cpu\=2 -oout\ file profile sequences'
    end
  end

  describe '.command_path' do
    let(:path) { "/usr/bin/hmmsearch" }

    before { described_class.command_path = path }

    after  { described_class.command_path = nil }

    it 'alternates the command' do
      expect(obj.to_a.first).to eq path
      expect(obj.to_s.split(/\s/).first).to eq path
    end
  end
end
