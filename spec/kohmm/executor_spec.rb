RSpec.describe KOHMM::Executor do
  subject(:executor) { described_class.new(config) }

  let(:config) { KOHMM::Config.new }

  describe '#execute' do
    let(:methods_to_be_executed) {
      %i[read_thresholds setup_directories
         run_hmmsearch search_hit_genes output_hits]
    }

    before do
      config.query = "file"
      methods_to_be_executed.each do |method|
        allow(executor).to receive(method)
      end
    end

    context 'when it is not reannotation' do
      it 'executes other methods with correct order' do
        methods_to_be_executed.each do |method|
          expect(executor).to receive(method).ordered
        end
        executor.execute
      end
    end

    context 'when it is reannotation' do
      before do
        config.reannotation = true
        config.hmmsearch_result_dir = "tmp/hmmsearch_result"
      end

      it 'executes other methods with correct order' do
        methods_to_be_executed.grep_v(:run_hmmsearch).each do |method|
          expect(executor).to receive(method).ordered
        end
        executor.execute
      end

      it 'does not execute run_hmmsearch' do
        expect(executor).not_to receive(:run_hmmsearch)
        executor.execute
      end
    end
  end
end
