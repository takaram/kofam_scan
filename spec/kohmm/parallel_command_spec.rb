RSpec.describe KOHMM::ParallelCommand do
  describe '.create' do
    context 'without arguments' do
      context 'when parallel command is available' do
        before do
          allow(described_class).to receive(:parallel_available?).and_return true
        end

        it 'returns an instance of KOHMM::ParallelCommand::Parallel' do
          expect(described_class.create).to be_an_instance_of described_class::Parallel
        end
      end

      context 'when parallel command is not available' do
        before do
          allow(described_class).to receive(:parallel_available?).and_return false
        end

        context 'and xargs has -P option' do
          before do
            allow(described_class).to receive(:xargs_available?).and_return true
          end

          it 'returns an instance of KOHMM::ParallelCommand::Xargs' do
            expect(described_class.create).to be_an_instance_of described_class::Xargs
          end
        end

        context 'and xargs does not have -P option' do
          before do
            allow(described_class).to receive(:xargs_available?).and_return false
          end

          it 'raises an error' do
            expect { described_class.create }.to raise_error RuntimeError
          end
        end
      end
    end

    context 'with argument' do
      context 'when argument is command name' do
        it 'returns an instance corresponding to the argument' do
          parallel = described_class.create("parallel")
          expect(parallel).to be_an_instance_of described_class::Parallel
          xargs = described_class.create(:xargs)
          expect(xargs).to be_an_instance_of described_class::Xargs
        end
      end

      context 'when argument is full path' do
        subject { described_class.create(path) }

        context 'parallel' do
          let(:path) { "/usr/local/bin/parallel" }
          it { should be_an_instance_of described_class::Parallel }
        end

        context 'xargs' do
          let(:path) { "/usr/bin/xargs" }
          it { should be_an_instance_of described_class::Xargs }
        end
      end
    end
  end

  def stub_popen_run(command_to_stub)
    allow(Open3).to receive(:popen_run).with(array_including(command_to_stub), any_args)
                                       .and_wrap_original do |method, *args, &block|
      status = instance_double(Process::Status)
      allow(status).to receive(:success?).and_return(is_success)

      result = method.call(*args, &block)
      result[-1] = status
      result
    end
  end

  describe '.parallel_available?' do
    before do
      stub_popen_run(/parallel/)
    end

    context 'when parallel command is available' do
      let(:is_success) { true }
      it 'returns true' do
        expect(described_class.parallel_available?).to be_truthy
      end
    end

    context 'when parallel command is not available' do
      let(:is_success) { false }
      it 'returns false' do
        expect(described_class.parallel_available?).to be_falsey
      end
    end
  end

  describe '.xargs_available?' do
    before do
      stub_popen_run(/xargs/)
    end

    context 'when xargs command is available' do
      let(:is_success) { true }
      it 'returns true' do
        expect(described_class.xargs_available?).to be_truthy
      end
    end

    context 'when xargs command is not available' do
      let(:is_success) { false }
      it 'returns false' do
        expect(described_class.xargs_available?).to be_falsey
      end
    end
  end
end

RSpec.shared_examples 'a parallel command object' do |command, cpu_option|
  describe '#parallel_command' do
    context 'when full path is fed' do
      it 'returns the path' do
        path = "/usr/local/bin/#{command}"
        obj = described_class.new(full_path: path, command: "some_cmd")
        expect(obj.parallel_command).to eq path
      end
    end

    context 'when full path is not fed' do
      it "returns \"#{command}\"" do
        obj = described_class.new(command: "some_cmd")
        expect(obj.parallel_command).to eq command
      end
    end
  end

  describe '#build_command' do
    subject(:built_command) {
      described_class.new(cpu: 2, command: cmd).build_command
    }
    let(:cmd) { "some_command {}" }

    it "includes #{cpu_option} n" do
      expect(built_command).to satisfy { |array|
        array.each_cons(2).any? { |a| a == [cpu_option, "2"] }
      }
    end

    it 'includes the command' do
      expect(built_command).to include *cmd.split
    end

    it 'starts with parallel_command' do
      expect(built_command.first).to eq command
    end

    it 'raises error when command is not set' do
      expect { described_class.new.build_command }
        .to raise_error KOHMM::ParallelCommand::CommandNotSet
    end
  end

  describe '#exec' do
    it "runs #{command} and returns an array of stdout/stderr string" do
      parallel = described_class.new(command: "echo {} {}", inputs: "a\nb")
      out, err = parallel.exec

      expect(out).to eq "a a\nb b\n"
      expect(err).to eq ""
    end
  end
end

RSpec.describe KOHMM::ParallelCommand::Parallel do
  it_behaves_like 'a parallel command object', "parallel", "-j"
end

RSpec.describe KOHMM::ParallelCommand::Xargs do
  it_behaves_like 'a parallel command object', "xargs", "-P"
end
