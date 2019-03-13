require_relative 'shared_contexts'

RSpec.describe KofamScan::OutputFormatter::SimpleTabularFormatter do
  describe '#format' do
    context 'the simplest context' do
      include_context 'one hit for one gene'
      let(:expected_output) { <<~RESULT }
        gene1
        gene2\tK00002
        gene3
        gene4\tK00003
        gene5
      RESULT

      it 'gives the right output' do
        expect(output).to eq expected_output
      end
    end

    context 'multiple hits for one gene' do
      include_context description

      it 'takes all the KO in the order of score' do
        gene1_kos = output.split(/\n/).grep(/^gene1\t/).map { |l| l.split.last }
        expect(gene1_kos).to match(%w[K00002 K00001])
      end

      it 'has the same number of lines as hits for one gene' do
        gene1_lines = output.split(/\n/).grep(/^gene1/)
        expect(gene1_lines.size).to eq 2
      end
    end

    context 'when report_unannotated is false' do
      include_examples description, <<~RESULT
        gene2\tK00002
        gene4\tK00003
      RESULT
    end

    context 'with a long gene name' do
      include_context description

      it 'does not truncate the gene name' do
        gene_name_out = output.split.first
        expect(gene_name_out).to eq long_name
      end
    end
  end
end
