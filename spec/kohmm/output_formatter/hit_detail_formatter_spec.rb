require_relative 'shared_contexts'

RSpec.describe KOHMM::OutputFormatter::HitDetailFormatter do
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
    end

    context 'multiple hits for one KO' do
      include_context description

      it 'includes all the hits for the KO' do
        k00001_lines = output.split(/\n/).grep(/K00001/)
        expect(k00001_lines.size).to eq 2
      end
    end

    context 'with very long gene name' do
      before do
        result << KOHMM::Result::Hit.new("a" * 100, ko1, 200, 1e-10)
      end
      include_context :basic_context

      char_len = 19

      it "truncates the gene name to #{char_len} characters" do
        line = output.split(/\n/)[-1]
        expect(line).to match(/\ba{#{char_len}}\b/)
      end
    end
  end
end
