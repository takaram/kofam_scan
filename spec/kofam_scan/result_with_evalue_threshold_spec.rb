require_relative 'result_examples'

RSpec.describe KofamScan::ResultWithEvalueThreshold do
  include_context 'result context'

  let(:initialize_result) { described_class.new(query_list, e_value_threshold) }

  let(:e_value_threshold) { 0.01 }

  it_behaves_like 'result common'

  describe 'each hit' do
    include_context 'hit context'

    it_behaves_like 'hit common'

    describe '#above_threshold?' do
      subject { hit1.above_threshold? }

      let(:hit1_e_value) { 9.5e-51 }

      context 'when the E-value is equal to the threshold' do
        let(:e_value_threshold) { hit1_e_value }

        it { is_expected.to be_truthy }
      end

      context 'when the E-value is above the threshold' do
        let(:e_value_threshold) { hit1_e_value * 0.99 }

        it { is_expected.to be_falsy }
      end

      context 'when the E-value is below the threshold' do
        let(:e_value_threshold) { hit1_e_value * 1.01 }

        it { is_expected.to be_truthy }
      end
    end
  end
end
