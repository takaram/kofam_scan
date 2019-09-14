require_relative 'shared_examples'

RSpec.describe KofamScan::Result::WithThresholdScale do
  include_context 'result context'

  let(:initialize_result) { KofamScan::Result.create(query_list, threshold_scale: threshold_scale) }

  let(:threshold_scale) { 1 }

  it_behaves_like 'result common'

  describe 'each hit' do
    include_context 'hit context'

    it_behaves_like 'hit common'

    describe '#above_threshold?' do
      subject { hit1.above_threshold? }

      context 'when threshold scale is smaller than 1' do
        let(:threshold_scale) { 0.8 }

        context 'when the score is equal to the threshold' do
          let(:ko1_threshold) { "170.20" }

          it { is_expected.to be_truthy }
        end

        context 'when the score is above the threshold' do
          let(:ko1_threshold) { "170.19" }

          it { is_expected.to be_truthy }
        end

        context 'when the score is below the threshold and above the scaled threshold' do
          let(:ko1_threshold) { "170.21" }

          it { is_expected.to be_truthy }
        end

        context 'when the score is equal to the scaled threshold' do
          let(:ko1_threshold) { "212.75" }

          it { is_expected.to be_truthy }
        end

        context 'when the score is below the scaled threshold' do
          let(:ko1_threshold) { "212.80" }

          it { is_expected.to be_falsy }
        end
      end

      context 'when threshold scale is larger than 1' do
        let(:threshold_scale) { 1.6 }

        context 'when the score is equal to the threshold' do
          let(:ko1_threshold) { "170.20" }

          it { is_expected.to be_falsy }
        end

        context 'when the score is above the threshold and below the scaled threshold' do
          let(:ko1_threshold) { "170.19" }

          it { is_expected.to be_falsy }
        end

        context 'when the score is equal to the scaled threshold' do
          let(:ko1_threshold) { "106.375" }

          it { is_expected.to be_truthy }
        end

        context 'when the score is above the scaled threshold' do
          let(:ko1_threshold) { "106.37" }

          it { is_expected.to be_truthy }
        end

        context 'when the score is below the threshold' do
          let(:ko1_threshold) { "170.21" }

          it { is_expected.to be_falsy }
        end

        context 'when the threshold of the KO is unavailable' do
          subject { hit3.above_threshold? }

          it { is_expected.to be_falsy }
        end
      end
    end
  end
end
