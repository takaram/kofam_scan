require_relative 'shared_contexts'

RSpec.describe KOHMM::OutputFormatter::HitDetailFormatter do
  def output_array
    output_lines = output.split(/\n/).grep_v(/^#/)
    output_lines.map do |line|
      mark = line.slice!(0, 1)
      [mark, *line.split(nil, 5)]
    end
  end

  describe '#format' do
    context 'the simplest context' do
      include_context 'one hit for one gene'
      let(:expected_output) { <<~RESULT }
        # gene name           KO      score   E-value KO definition
        #-------------------- ------ ------ --------- ---------------------
          gene1               K00001   50.1    0.0009 alcohol dehydrogenase [EC:1.1.1.1]
        * gene2               K00002  180.0     5e-05 alcohol dehydrogenase (NADP+) [EC:1.1.1.2]
        * gene4               K00003  200.0   1.2e-10 homoserine dehydrogenase [EC:1.1.1.3]
      RESULT

      it 'gives the right output' do
        expect(output).to eq expected_output
      end
    end

    context 'multiple hits for one gene' do
      include_context description

      it 'includes all the hits for the gene' do
        gene1_lines = output.split(/\n/).grep(/gene1/)
        expect(gene1_lines.size).to eq 3
      end

      it 'gives result in the order of gene name and score' do
        gene_ko_pair = output_array.map { |line| line.values_at(1, 2) }
        expect(gene_ko_pair).to match [
          %w[gene1 K00002],
          %w[gene1 K00001],
          %w[gene1 K00003],
          %w[gene4 K00002]
        ]
      end
    end

    context 'multiple hits for one KO' do
      include_context description

      it 'includes all the hits for the KO' do
        k00001_lines = output.split(/\n/).grep(/K00001/)
        expect(k00001_lines.size).to eq 2
      end
    end

    context 'with very long gene name' do
      include_context 'basic context'

      let(:result) { KOHMM::Result.new([long_name]) }
      let(:long_name) { "a" * 100 }

      before do
        result << KOHMM::Result::Hit.new(long_name, ko1, 200, 1e-10)
      end

      char_len = 19

      it "truncates the gene name to #{char_len} characters" do
        line = output.split(/\n/)[-1]
        expect(line).to match(/\ba{#{char_len}}\b/)
      end
    end

    context 'when report_unannotated is true' do
      include_examples description, <<~RESULT
        # gene name           KO      score   E-value KO definition
        #-------------------- ------ ------ --------- ---------------------
          gene1               K00001   50.1    0.0009 alcohol dehydrogenase [EC:1.1.1.1]
        * gene2               K00002  180.0     5e-05 alcohol dehydrogenase (NADP+) [EC:1.1.1.2]
          gene3               -           -         - -
        * gene4               K00003  200.0   1.2e-10 homoserine dehydrogenase [EC:1.1.1.3]
          gene5               -           -         - -
      RESULT
    end
  end
end
