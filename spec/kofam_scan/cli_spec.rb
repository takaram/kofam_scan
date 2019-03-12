require 'rspec/temp_dir'
require 'fileutils'
require 'kofam_scan/cli'

RSpec.describe KofamScan::CLI do
  describe '.run' do
    subject(:execute_run) { described_class.run(options) }

    let(:options) { ["query"] }

    before do
      allow(KofamScan::Executor).to receive(:execute)
    end

    context 'with -h or --help option' do
      it 'prints help message and exit' do
        %w[-h --help].each do |option|
          expect { described_class.run([option]) }.to(
            output(/\AUsage/i).to_stdout.and exit_script.successfully
          )
        end
      end
    end

    context 'with vaild arguments' do
      context 'with config file' do
        unless File.exist?(KofamScan::DEFAULT_CONFIG_FILE)
          around do |example|
            IO.write(KofamScan::DEFAULT_CONFIG_FILE, "cpu: 1\n")
            example.run
            File.delete(KofamScan::DEFAULT_CONFIG_FILE)
          end
        end

        it 'invokes KofamScan::Executor.execute' do
          expect(KofamScan::Executor).to receive(:execute)
          described_class.run(options)
        end
      end

      context 'without config file' do
        if File.exist?(KofamScan::DEFAULT_CONFIG_FILE)
          include_context 'uses temp dir'
          around do |example|
            tmp_file = File.expand_path("tmp", temp_dir)
            FileUtils.mv(KofamScan::DEFAULT_CONFIG_FILE, tmp_file)
            example.run
            FileUtils.mv(tmp_file, KofamScan::DEFAULT_CONFIG_FILE)
          end
        end

        it 'invokes KofamScan::Executor.execute' do
          expect(KofamScan::Executor).to receive(:execute)
          described_class.run(options)
        end
      end
    end

    context 'with invalid options' do
      before do
        allow_any_instance_of(KofamScan::CLI::OptionParser).to(
          receive(:parse!).and_raise ::OptionParser::ParseError
        )
      end

      it 'shows usage to stderr and exit with error' do
        expect { execute_run }.to(
          output(/Usage/i).to_stderr.and exit_script.unsuccessfully
        )
      end
    end

    context 'without query' do
      let(:options) { %w[-o out_file] }

      it 'shows an error message to stderr and exit with error' do
        expect { execute_run }.to(
          output(/specify a query/i).to_stderr.and exit_script.unsuccessfully
        )
      end
    end

    context 'with too many args' do
      let(:options) { %w[file_a file_b] }

      it 'shows an error message to stderr and exit with error' do
        expect { execute_run }.to(
          output(/too many/i).to_stderr.and exit_script.unsuccessfully
        )
      end
    end

    context 'when Executor.execute raises an error' do
      before { allow(KofamScan::Executor).to receive(:execute).and_raise exception }

      context 'when the error is KofamScan::Error' do
        let(:exception) { KofamScan::Error }

        it 'shows an error message to stderr and exit with error' do
          expect { execute_run }.to(
            output.to_stderr.and exit_script.unsuccessfully
          )
        end
      end

      context 'when the error is not KofamScan::Error' do
        let(:exception) { ArgumentError }

        it 'lets the error go through' do
          expect { execute_run }.to raise_error exception
        end
      end
    end
  end
end
