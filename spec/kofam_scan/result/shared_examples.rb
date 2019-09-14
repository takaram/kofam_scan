require 'stringio'

RSpec.shared_context 'result context' do
  let(:hmmsearch_result1) { spec_root.join('test_data', 'tabular', 'K00001').open }
  let(:hmmsearch_result2) { spec_root.join('test_data', 'tabular', 'K00004').open }
  let(:hmmsearch_result3) { spec_root.join('test_data', 'tabular', 'K00002').open }

  let(:query_list) do
    [hmmsearch_result1, hmmsearch_result2].flat_map do |f|
      result = f.each_with_object([]) do |line, arr|
        arr << line.slice(/^\S+/) unless line.start_with?('#')
      end
      f.rewind
      result
    end.uniq.sort
  end

  let(:result) do
    result = initialize_result
    result.parse(hmmsearch_result1, hmmsearch_result2, hmmsearch_result3)
    result
  end

  let(:ko1_threshold) { "170.20" }

  before { KofamScan::KO.parse(StringIO.new(<<~KOLIST)) }
    knum	threshold	score_type	profile_type	F-measure	nseq	nseq_used	alen	mlen	eff_nseq	re/pos	definition
    K00001	#{ko1_threshold}	domain	trim	0.244676	1458	1033	1718	320	10.61	0.590	alcohol dehydrogenase [EC:1.1.1.1]
    K00002	-	-	-	-	1261	-	-	-	-	-	alcohol dehydrogenase (NADP+) [EC:1.1.1.2]
    K00004	277.79	full	all	0.925732	857	652	781	354	3.38	0.590	(R,R)-butanediol dehydrogenase [EC:1.1.1.4 1.1.1.- 1.1.1.303]
  KOLIST

  after do
    [hmmsearch_result1, hmmsearch_result2, hmmsearch_result3].each(&:close)
    KofamScan::KO.instance_variable_set(:@instances, nil)
  end
end

RSpec.shared_examples 'result common' do
  describe '#for_ko' do
    subject(:result_for_ko) { result.for_ko("K00001") }

    it { is_expected.to be_a_kind_of Enumerable }

    it 'has the right number of hits' do
      expect(result_for_ko.count).to eq 6
    end

    it 'includes hits of the designated KO only' do
      expect(result_for_ko).to all(satisfy { |hit| hit.ko.name == "K00001" })
    end
  end

  describe '#for_gene' do
    subject(:result_for_gene) { result.for_gene("apr:Apre_1614") }

    it { is_expected.to be_kind_of Enumerable }

    it 'has the right number of hits' do
      expect(result_for_gene.count).to eq 2
      expect(result.for_gene("apr:Apre_1060").count).to eq 1
    end

    it 'includes hits of the designated gene only' do
      expect(result_for_gene).to all(satisfy { |hit| hit.gene_name == "apr:Apre_1614" })
    end
  end

  describe '#parse' do
    context 'when a hit ko is unknown' do
      before { KofamScan::KO.instance_variable_get(:@instances).delete("K00001") }

      it 'raises KofamScan::Error' do
        result = initialize_result
        expect {
          result.parse(hmmsearch_result1, hmmsearch_result2)
        }.to raise_error KofamScan::Error
      end
    end
  end
end

RSpec.shared_context 'hit context' do
  let(:hits) { result.for_gene("apr:Apre_1614") }
  let(:hit1) { hits.find { |hit| hit.ko.name == "K00001" } }
  let(:hit2) { hits.find { |hit| hit.ko.name == "K00004" } }
  let(:hit3) { result.for_ko("K00002").first }
end

RSpec.shared_examples 'hit common' do
  describe '#gene_name' do
    it 'returns the right name' do
      expect(hit1.gene_name).to eq "apr:Apre_1614"
      expect(hit2.gene_name).to eq "apr:Apre_1614"
    end
  end

  describe '#ko' do
    it 'returns a KO object' do
      expect(hit1.ko).to be_kind_of KofamScan::KO
    end

    specify 'returned KO has the right name' do
      expect(hit1.ko.name).to eq "K00001"
      expect(hit2.ko.name).to eq "K00004"
    end
  end

  describe '#score' do
    it 'returns the right score' do
      expect(hit1.score).to eq 170.2
      expect(hit2.score).to eq 277.8
    end

    context 'when score type is not avaliable' do
      it 'returns the score of full sequence' do
        expect(hit3.score).to eq 220.0
      end
    end
  end

  describe '#e_value' do
    it 'returns the right E-value' do
      expect(hit1.e_value).to eq 9.5e-51
      expect(hit2.e_value).to eq 1.2e-83
    end

    context 'when score type is not avaliable' do
      it 'returns the E-value of full sequence' do
        expect(hit3.e_value).to eq 5.4e-66
      end
    end
  end
end
