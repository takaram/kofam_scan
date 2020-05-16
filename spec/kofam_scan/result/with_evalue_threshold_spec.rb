require_relative 'shared_examples'

RSpec.describe KofamScan::Result::WithEvalueThreshold do
  include_context 'result context'

  let(:initialize_result) { KofamScan::Result.create(query_list, e_value_threshold: e_value_threshold) }

  let(:e_value_threshold) { 0.01 }

  it_behaves_like 'result common'

  describe 'each hit' do
    include_context 'hit context'

    it_behaves_like 'hit common'

    describe '#above_threshold?' do
      subject { hit1.above_threshold? }

      let(:hit1_e_value) { 9.5e-51 }

      shared_examples 'with threshold conditions' do
        context 'when the score is equal to the threshold' do
          let(:ko1_threshold) { "170.20" }

          it { is_expected.to(e_value_cond_passes ? be_truthy : be_falsy) }
        end

        context 'when the score is above the threshold' do
          let(:ko1_threshold) { "106.37" }

          it { is_expected.to(e_value_cond_passes ? be_truthy : be_falsy) }
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

      context 'when the E-value is equal to the threshold' do
        let(:e_value_threshold) { hit1_e_value }
        let(:e_value_cond_passes) { true }

        include_context 'with threshold conditions'
      end

      context 'when the E-value is above the threshold' do
        let(:e_value_threshold) { hit1_e_value * 0.99 }
        let(:e_value_cond_passes) { false }

        include_context 'with threshold conditions'
      end

      context 'when the E-value is below the threshold' do
        let(:e_value_threshold) { hit1_e_value * 1.01 }
        let(:e_value_cond_passes) { true }

        include_context 'with threshold conditions'
      end
    end
  end
end
