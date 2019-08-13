require_relative 'result_examples'

RSpec.describe KofamScan::Result do
  include_context 'result context'

  let(:initialize_result) { described_class.new(query_list) }

  it_behaves_like 'result common'

  describe 'each hit' do
    include_context 'hit context'

    it_behaves_like 'hit common'

    describe '#above_threshold?' do
      context 'when the score is equal to the threshold' do
        subject { hit1.above_threshold? }

        it { is_expected.to be_truthy }
      end

      context 'when the score is above the threshold' do
        subject { hit2.above_threshold? }

        it { is_expected.to be_truthy }
      end

      context 'when the score is below the threshold' do
        subject { hit3.above_threshold? }

        it { is_expected.to be_falsy }
      end

      context 'when the threshold of the KO is unavailable' do
        subject { hit4.above_threshold? }

        it { is_expected.to be_falsy }
      end
    end
  end
end
