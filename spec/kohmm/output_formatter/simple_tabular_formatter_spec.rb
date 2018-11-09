require_relative 'shared_contexts'

RSpec.describe KOHMM::OutputFormatter::SimpleTabularFormatter do
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

      it 'takes the KO with highest score' do
        expect(output).to match(/^gene1\tK00002$/)
      end

      it 'has only one line for one gene' do
        gene1_lines = output.split(/\n/).grep(/^gene1/)
        expect(gene1_lines.size).to eq 1
      end
    end
  end
end
