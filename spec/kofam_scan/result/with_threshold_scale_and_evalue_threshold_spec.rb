require_relative 'shared_examples'

RSpec.describe KofamScan::Result::WithThresholdScaleAndEvalueThreshold do
  include_context 'result context'

  let(:initialize_result) do
    KofamScan::Result.create(query_list,
                             threshold_scale:   threshold_scale,
                             e_value_threshold: e_value_threshold)
  end

  let(:threshold_scale) { 1 }
  let(:e_value_threshold) { 0.01 }

  it_behaves_like 'result common'

  describe 'each hit' do
    include_context 'hit context'

    it_behaves_like 'hit common'

    describe '#above_threshold?' do
      subject { hit1.above_threshold? }

      let(:hit1_e_value) { 9.5e-51 }

      shared_examples 'with E-value threshold changes' do
        context 'when the E-value is equal to the threshold' do
          let(:e_value_threshold) { hit1_e_value }

          it { is_expected.to(threshold_cond_passes ? be_truthy : be_falsy) }
        end

        context 'when the E-value is above the threshold' do
          let(:e_value_threshold) { hit1_e_value * 0.99 }

          it { is_expected.to be_falsy }
        end

        context 'when the E-value is below the threshold' do
          let(:e_value_threshold) { hit1_e_value * 1.01 }

          it { is_expected.to(threshold_cond_passes ? be_truthy : be_falsy) }
        end
      end

      context 'when threshold scale is smaller than 1' do
        let(:threshold_scale) { 0.8 }

        context 'when the score is equal to the threshold' do
          let(:ko1_threshold) { "170.20" }
          let(:threshold_cond_passes) { true }

          include_context 'with E-value threshold changes'
        end

        context 'when the score is above the threshold' do
          let(:ko1_threshold) { "170.19" }
          let(:threshold_cond_passes) { true }

          include_context 'with E-value threshold changes'
        end

        context 'when the score is below the threshold and above the scaled threshold' do
          let(:ko1_threshold) { "170.21" }
          let(:threshold_cond_passes) { true }

          include_context 'with E-value threshold changes'
        end

        context 'when the score is equal to the scaled threshold' do
          let(:ko1_threshold) { "212.75" }
          let(:threshold_cond_passes) { true }

          include_context 'with E-value threshold changes'
        end

        context 'when the score is below the scaled threshold' do
          let(:ko1_threshold) { "212.80" }
          let(:threshold_cond_passes) { false }

          include_context 'with E-value threshold changes'
        end
      end

      context 'when threshold scale is larger than 1' do
        let(:threshold_scale) { 1.6 }

        context 'when the score is equal to the threshold' do
          let(:ko1_threshold) { "170.20" }
          let(:threshold_cond_passes) { false }

          include_context 'with E-value threshold changes'
        end

        context 'when the score is above the threshold and below the scaled threshold' do
          let(:ko1_threshold) { "170.19" }
          let(:threshold_cond_passes) { false }

          include_context 'with E-value threshold changes'
        end

        context 'when the score is equal to the scaled threshold' do
          let(:ko1_threshold) { "106.375" }
          let(:threshold_cond_passes) { true }

          include_context 'with E-value threshold changes'
        end

        context 'when the score is above the scaled threshold' do
          let(:ko1_threshold) { "106.37" }
          let(:threshold_cond_passes) { true }

          include_context 'with E-value threshold changes'
        end

        context 'when the score is below the threshold' do
          let(:ko1_threshold) { "170.21" }
          let(:threshold_cond_passes) { false }

          include_context 'with E-value threshold changes'
        end

        context 'when the threshold of the KO is unavailable' do
          subject { hit3.above_threshold? }

          let(:threshold_cond_passes) { false }

          include_context 'with E-value threshold changes'
        end
      end
    end
  end
end
