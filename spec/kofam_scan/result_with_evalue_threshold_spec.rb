require_relative 'result_examples'

RSpec.describe KofamScan::ResultWithEvalueThreshold do
  include_context 'result context'

  let(:result) do
    result = described_class.new(query_list, e_value_threshold)
    result.parse(hmmsearch_result1, hmmsearch_result2)
    result
  end

  let(:e_value_threshold) { 0.01 }

  it_behaves_like 'result common'

  describe 'each hit' do
    include_context 'hit context'

    it_behaves_like 'hit common'

    describe '#above_threshold?' do
      subject { hit1.above_threshold? }

      context 'when the E-value is equal to the threshold' do
        let(:e_value_threshold) { hit1.e_value }

        it { is_expected.to be_truthy }
      end

      context 'when the E-value is above the threshold' do
        let(:e_value_threshold) { hit1.e_value * 1.01 }

        it { is_expected.to be_truthy }
      end

      context 'when the E-value is below the threshold' do
        let(:e_value_threshold) { hit1.e_value * 0.99 }

        it { is_expected.to be_falsy }
      end
    end
  end
end
