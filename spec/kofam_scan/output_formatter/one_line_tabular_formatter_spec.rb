require_relative 'shared_contexts'

RSpec.describe KofamScan::OutputFormatter::OneLineTabularFormatter do
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
        expect(output).to match(/^gene1\tK00002\tK00001$/)
      end

      it 'has only one line for one gene' do
        gene1_lines = output.split(/\n/).grep(/^gene1/)
        expect(gene1_lines.size).to eq 1
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
