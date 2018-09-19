RSpec.describe KOHMM do
  subject { KOHMM.new }

  describe '#execute_pipeline' do
    let(:methods_to_be_executed) {
      %i[parse_options read_thresholds setup_directories
         run_hmmsearch search_hit_genes output_hits]
    }

    before do
      methods_to_be_executed.each do |method|
        allow(subject).to receive(method)
      end
    end

    context 'when it is not reannotation' do
      before { stub_const("ARGV", ["file"]) }

      it 'executes other methods with correct order' do
        methods_to_be_executed.each do |method|
          expect(subject).to receive(method).ordered
        end
        subject.execute_pipeline
      end
    end

    context 'when it is reannotation' do
      before do
        stub_const("ARGV", %w[-r tmp/hmmsearch_result file])
        allow(subject).to receive(:parse_options).and_call_original
      end

      it 'executes other methods with correct order' do
        methods_to_be_executed.grep_v(:run_hmmsearch).each do |method|
          expect(subject).to receive(method).ordered
        end
        subject.execute_pipeline
      end

      it 'does not execute run_hmmsearch' do
        expect(subject).not_to receive(:run_hmmsearch)
        subject.execute_pipeline
      end
    end
  end

  describe '#parse_options' do
    context 'with -h or --help option' do
      it 'prints help message' do
        expect { subject.parse_options(["-h"])     }.to output(/\AUsage/i).to_stdout.and exit_script.successfully
        expect { subject.parse_options(["--help"]) }.to output(/\AUsage/i).to_stdout.and exit_script.successfully
      end
    end

    context 'with valid options' do
      it 'sets correct values to config' do
        config = subject.config
        file = "file"
        query = "query"

        expect(config).to receive(:output_file=).with file
        expect(config).to receive(:query=).with query

        subject.parse_options(["-o", file, query])
      end
    end

    context 'with invalid options' do
      it 'exits with exit status > 0' do
        allow(subject.option_parser).to receive(:parse!).and_raise
        expect { subject.parse_options }.to output(/Usage/i).to_stderr.and exit_script.unsuccessfully
      end
    end

    context 'without query' do
      it 'exits with exit status > 0' do
        expect { subject.parse_options(%w[-o out_file]) }.to output(/specify a query/i).to_stderr.and exit_script.unsuccessfully
      end
    end

    context 'with too many args' do
      it 'exits with exit status > 0' do
        expect { subject.parse_options(%w[arg1 arg2]) }.to output(/too many/i).to_stderr.and exit_script.unsuccessfully
      end
    end
  end
end
