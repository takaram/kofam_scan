require 'rspec/temp_dir'
require 'kofam_scan/output_rearranger'

RSpec.describe KofamScan::OutputRearranger do
  include_context 'uses temp dir'

  let(:rearranger) { described_class.new(from_dir, to_dir) }
  let(:from_dir) { spec_root.join('test_data', 'output') }
  let(:to_dir) { temp_dir_path }
  let(:result_with_one) { to_dir + "apr:Apre_1060" }
  let(:result_with_two) { to_dir + "apr:Apre_1614" }

  before do
    KofamScan::KO.parse(StringIO.new(<<~KOLIST))
      knum	threshold	score_type	profile_type	F-measure	nseq	nseq_used	alen	mlen	eff_nseq	re/pos	definition
      K00001	170.20	domain	trim	0.244676	1458	1033	1718	320	10.61	0.590	alcohol dehydrogenase [EC:1.1.1.1]
      K00004	277.79	full	all	0.925732	857	652	781	354	3.38	0.590	(R,R)-butanediol dehydrogenase [EC:1.1.1.4 1.1.1.- 1.1.1.303]
    KOLIST
    rearranger.rearrange
  end

  after { KofamScan::KO.instance_variable_set(:@instances, nil) }

  describe '#rearrange' do
    it 'creates the same number of files as unique sequences' do
      file_list = to_dir.children
      expect(file_list.size).to eq 13
    end

    it 'creates a file starting with "Sequence: {{sequence_name}}"' do
      header_line1 = result_with_one.each_line { |line| break line.chomp }
      header_line2 = result_with_two.each_line { |line| break line.chomp }

      expect(header_line1).to eq "Sequence: apr:Apre_1060"
      expect(header_line2).to eq "Sequence: apr:Apre_1614"
    end

    context 'when the sequence has only one hit' do
      it 'creates a file containing exactly one entry' do
        count = result_with_one.each_line.count { |line| line =~ /^>>/ }
        expect(count).to eq 1
      end
    end

    context 'when the sequence has two hits' do
      it 'creates a file containing exactly two entries' do
        count = result_with_two.each_line.count { |line| line =~ /^>>/ }
        expect(count).to eq 2
      end
    end

    describe 'each entry' do
      let(:entries) { result_with_two.each_line.slice_before(/^>>/).drop(1) }

      it 'has 5n + 7 lines' do
        entries.each do |entry|
          expect(entry.size % 5).to eq 2
        end
      end
    end
  end
end
