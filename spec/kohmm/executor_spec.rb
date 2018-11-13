RSpec.describe KOHMM::Executor do
  subject { described_class.new(config) }

  let(:config) { KOHMM::Config.new }

  describe '#execute' do
    let(:methods_to_be_executed) {
      %i[read_thresholds setup_directories
         run_hmmsearch search_hit_genes output_hits]
    }

    before do
      config.query = "file"
      methods_to_be_executed.each do |method|
        allow(subject).to receive(method)
      end
    end

    context 'when it is not reannotation' do
      it 'executes other methods with correct order' do
        methods_to_be_executed.each do |method|
          expect(subject).to receive(method).ordered
        end
        subject.execute
      end
    end

    context 'when it is reannotation' do
      before do
        config.reannotation = true
        config.hmmsearch_result_dir = "tmp/hmmsearch_result"
      end

      it 'executes other methods with correct order' do
        methods_to_be_executed.grep_v(:run_hmmsearch).each do |method|
          expect(subject).to receive(method).ordered
        end
        subject.execute
      end

      it 'does not execute run_hmmsearch' do
        expect(subject).not_to receive(:run_hmmsearch)
        subject.execute
      end
    end
  end
end
