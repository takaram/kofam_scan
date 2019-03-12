require 'stringio'

RSpec.describe KofamScan::KO do
  let(:k00001) { described_class["K00001"] }
  let(:k00005) { described_class["K00005"] }
  let(:k01977) { described_class["K01977"] }

  before { described_class.parse(StringIO.new(<<~KOLIST)) }
    knum	threshold	score_type	profile_type	F-measure	nseq	nseq_used	alen	mlen	eff_nseq	re/pos	definition
    K00001	297.73	domain	trim	0.244676	1458	1033	1718	320	10.61	0.590	alcohol dehydrogenase [EC:1.1.1.1]
    K00005	344.01	full	all	0.901895	1381	965	796	365	2.82	0.590	glycerol dehydrogenase [EC:1.1.1.6]
    K01977	-	-	-	-	16376	-	-	-	-	-	glycerol dehydrogenase [EC:1.1.1.6]
  KOLIST

  after { described_class.instance_variable_set(:@instances, nil) }

  describe '.all' do
    subject(:all_ko) { described_class.all }

    it 'returns an Enumerator' do
      expect(all_ko).to be_kind_of Enumerator
    end

    it 'returns an Enumerator which iterates for all KO' do
      expect(all_ko.map(&:name)).to contain_exactly("K00001", "K00005", "K01977")
    end
  end

  describe '#name' do
    it 'returns K number' do
      expect(k00001.name).to eq "K00001"
      expect(k00005.name).to eq "K00005"
    end
  end

  describe '#threshold' do
    it 'returns the threshold score' do
      expect(k00001.threshold).to eq 297.73
      expect(k00005.threshold).to eq 344.01
    end

    context 'when threshold is not available' do
      subject { k01977.threshold }

      it { is_expected.to be_nil }
    end
  end

  describe 'score type predicator' do
    describe '#full?' do
      subject { ko.full? }

      context 'when score_type is full' do
        let(:ko) { k00005 }

        it { is_expected.to be_truthy }
      end

      context 'when score_type is domain' do
        let(:ko) { k00001 }

        it { is_expected.to be_falsy }
      end

      context 'when score_type is not available' do
        let(:ko) { k01977 }

        it { is_expected.to be_falsy }
      end
    end

    describe '#domain?' do
      subject { ko.domain? }

      context 'when score type is full' do
        let(:ko) { k00005 }

        it { is_expected.to be_falsy }
      end

      context 'when score type is domain' do
        let(:ko) { k00001 }

        it { is_expected.to be_truthy }
      end

      context 'when score_type is not available' do
        let(:ko) { k01977 }

        it { is_expected.to be_falsy }
      end
    end
  end

  describe 'profile type predicator' do
    describe '#all?' do
      subject { ko.all? }

      context 'when profile_type is all' do
        let(:ko) { k00005 }

        it { is_expected.to be_truthy }
      end

      context 'when profile_type is trim' do
        let(:ko) { k00001 }

        it { is_expected.to be_falsy }
      end

      context 'when profile_type is not available' do
        let(:ko) { k01977 }

        it { is_expected.to be_falsy }
      end
    end

    describe '#trim?' do
      subject { ko.trim? }

      context 'when profile type is all' do
        let(:ko) { k00005 }

        it { is_expected.to be_falsy }
      end

      context 'when profile type is trim' do
        let(:ko) { k00001 }

        it { is_expected.to be_truthy }
      end

      context 'when profile_type is not available' do
        let(:ko) { k01977 }

        it { is_expected.to be_falsy }
      end
    end
  end

  describe '#f_measure' do
    it 'returns the value of F-measure' do
      expect(k00001.f_measure).to eq 0.244676
      expect(k00005.f_measure).to eq 0.901895
    end

    context 'when F-measure is not available' do
      subject { k01977.f_measure }

      it { is_expected.to be_nil }
    end
  end

  describe '#definition' do
    it 'returns the definition string' do
      expect(k00001.definition).to eq "alcohol dehydrogenase [EC:1.1.1.1]"
      expect(k00005.definition).to eq "glycerol dehydrogenase [EC:1.1.1.6]"
    end
  end

  describe '#threshold_available?' do
    subject { ko.threshold_available? }

    context 'when a threshold is available' do
      let(:ko) { k00001 }

      it { is_expected.to be_truthy }
    end

    context 'when a threshold is unavailable' do
      let(:ko) { k01977 }

      it { is_expected.to be_falsy }
    end
  end
end
