require 'rspec/temp_dir'

RSpec.describe KOHMM::Executor do
  subject(:executor) { described_class.new(config) }

  let(:config) { KOHMM::Config.new }

  describe '#execute' do
    let(:methods_to_be_executed) {
      %i[parse_ko setup_directories
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

  describe '#setup_directories' do
    include_context 'uses temp dir'

    shared_examples 'making tabular' do |tmp_path_blk|
      let(:tmp_path, &tmp_path_blk)

      before { config.tmp_dir = tmp_path.to_path }

      it 'makes tmp_dir/tabular' do
        executor.setup_directories
        expect(tmp_path + "tabular").to be_directory
      end
    end

    context 'when tmp_dir is not exist' do
      let(:new_dir) { temp_dir_path + "tmp" }

      before { config.tmp_dir = new_dir.to_path }

      it 'makes tmp_dir' do
        executor.setup_directories
        expect(new_dir).to be_directory
      end

      include_examples 'making tabular', -> { new_dir }
    end

    context 'when create_domain_alignment is true' do
      before do
        config.create_domain_alignment = true
        config.tmp_dir = temp_dir
      end

      it 'makes tmp_dir/output' do
        executor.setup_directories
        expect(temp_dir_path + "output").to be_directory
      end

      it 'makes tmp_dir/alignment' do
        executor.setup_directories
        expect(temp_dir_path + "alignment").to be_directory
      end

      include_examples 'making tabular', -> { temp_dir_path }
    end

    context 'when create_domain_alignment is false' do
      it 'does not make tmp_dir/output' do
        executor.setup_directories
        expect(temp_dir_path + "output").not_to be_exist
      end

      it 'does not make tmp_dir/alignment' do
        executor.setup_directories
        expect(temp_dir_path + "alignment").not_to be_exist
      end

      include_examples 'making tabular', -> { temp_dir_path }
    end
  end
end
