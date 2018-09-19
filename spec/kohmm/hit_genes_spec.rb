RSpec.describe KOHMM::HitGenes do
  let(:hit_genes) { described_class.new([file1, file2], threshold_list) }
  let(:threshold_list) { KOHMM::ThresholdList.new(threshold_io) }
  let(:threshold_io) {
    StringIO.new(<<~LIST)
      K00001	170.20	domain	trimming
      K00002	250.00	domain	all
      K00003	223.11	full	all
      K00004	277.80	full	all
    LIST
  }
  let(:file1) { File.expand_path("../test_data/K00001", __dir__) }
  let(:file2) { File.expand_path("../test_data/K00004", __dir__) }

  describe '#[]' do
    it 'returns a list of KO and score' do
      gene = hit_genes["apr:Apre_1614"]
      expect(gene).to contain_exactly(["K00001", 170.2], ["K00004", 277.8])
    end
  end

  shared_examples 'an alias of has_key?' do
    subject { hit_genes.public_send(method, key) }

    context 'when the key exists' do
      let(:key) { "apr:Apre_1614" }
      it { should be_truthy }
    end

    context 'when the key does not exist' do
      let(:key) { "apr:xxxxx" }
      it { should be_falsey }
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

  describe '#each' do
    it 'iterates with gene names and self[gene_name]' do
      expect { |b| hit_genes.each(&b) }.to yield_with_args(
        [String, all(match([/\AK\d{5}\z/, Float]))]
      )
    end

    it 'does not repeat the same gene' do
      gene_list = hit_genes.each.map { |name, _info| name }
      expect { gene_list.uniq! }.not_to change { gene_list.size }
    end
  end
end
