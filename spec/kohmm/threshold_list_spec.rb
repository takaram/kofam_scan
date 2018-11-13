require 'stringio'

RSpec.describe KOHMM::ThresholdList do
  let(:list_file) {
    StringIO.new("K00001\t325.73\tdomain\ttrimming\n" \
                 "K00005\t347.00\tfull\tall\n", 'r')
  }
  let(:list) { described_class.new(list_file) }

  shared_examples 'an alias of has_key?' do
    subject { list.public_send(method, key) }

    context 'when the key exists' do
      let(:key) { "K00001" }

      it { is_expected.to be_truthy }
    end

    context 'when the key does not exist' do
      let(:key) { "K99999" }

      it { is_expected.to be_falsey }
    end
  end

  describe '#has_key?' do
    let(:method) { :has_key? }

    it_behaves_like 'an alias of has_key?'
  end

  describe '#key?' do
    let(:method) { :key? }

    it_behaves_like 'an alias of has_key?'
  end

  describe '#[]' do
    subject { list[key] }

    context 'when the key exists' do
      let(:key) { "K00001" }

      it { is_expected.not_to be_nil }
    end

    context 'when the key does not exist' do
      let(:key) { "K99999" }

      it { is_expected.to be_nil }
    end
  end

  describe '#score' do
    it 'returns correct values' do
      expect(list.score("K00001")).to eq 325.73
      expect(list.score("K00005")).to eq 347.00
    end
  end

  describe '#full?' do
    subject { list.full?(ko) }

    context 'when full-sequence score used' do
      let(:ko) { "K00005" }

      it { is_expected.to be_truthy }
    end

    context 'when domain-sequence score used' do
      let(:ko) { "K00001" }

      it { is_expected.to be_falsey }
    end
  end

  describe '#domain?' do
    subject { list.domain?(ko) }

    context 'when full-sequence score used' do
      let(:ko) { "K00005" }

      it { is_expected.to be_falsey }
    end

    context 'when domain score used' do
      let(:ko) { "K00001" }

      it { is_expected.to be_truthy }
    end
  end

  describe "Each row of #{described_class}" do
    let(:row) { list[key] }

    describe '#full?' do
      subject { row.full? }

      context 'when full-sequence score used' do
        let(:key) { "K00005" }

        it { is_expected.to be_truthy }
      end

      context 'when domain-sequence score used' do
        let(:key) { "K00001" }

        it { is_expected.to be_falsey }
      end
    end

    describe '#domain?' do
      subject { row.domain? }

      context 'when full-sequence score used' do
        let(:key) { "K00005" }

        it { is_expected.to be_falsey }
      end

      context 'when domain score used' do
        let(:key) { "K00001" }

        it { is_expected.to be_truthy }
      end
    end

    describe '#score' do
      it 'returns correct values' do
        expect(list["K00001"].score).to eq 325.73
        expect(list["K00005"].score).to eq 347.00
      end
    end

    describe '#ko' do
      it 'returns ko name' do
        %w[K00001 K00005].each do |ko|
          expect(list[ko].ko).to eq ko
        end
      end
    end
  end
end
