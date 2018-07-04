require 'open3'

class KOHMM
  module ParallelCommand
    class << self
      def create(parallel_command = nil)
        if parallel_command
          if parallel_command =~ /\//
            # parallel_commandをパスで指定した場合
            command_name = File.basename(parallel_command, '.*')
            klass = const_get(command_name.capitalize)

            return klass.new(full_path: parallel_command)
          else
            # parallel_commandをコマンド名で指定した場合
            command_name = parallel_command
            klass = const_get(command_name.capitalize)

            return klass.new
          end
        end

        # parallel_commandを指定しなかった場合
        # parallelコマンドが存在すれば使う
        # parallelコマンドがなく、xargsで-Pオプションが使えればxargs
        # (一部のxargs実装は-Pがなく並列処理できない)
        if parallel_available?
          Parallel.new
        elsif xargs_available?
          Xargs.new
        else
          raise 'Could not find parallel command installed'
        end
      end

      def parallel_available?
        Open3.capture2("command -v parallel 2>/dev/null")[1].success?
      end

      def xargs_available?
        Open3.capture2("xargs -P1 </dev/null")[1].success?
      end
    end

    class Abstract
      attr_accessor :cpu, :command, :inputs

      def initialize(cpu: 1, command: nil, inputs: nil, full_path: nil)
        @cpu = cpu
        @command = command
        @inputs = inputs
        @full_path = full_path
      end

      def assemble_command
        raise CommandNotSet unless command

        cpu_option = self.class::CPU_OPTION
        additional_options = self.class::ADDITIONAL_OPTIONS
        [parallel_command, cpu_option, cpu, additional_options, command].join(" ")
      end

      def exec
        Open3.popen3(assemble_command) do |stdin, out, err, thread|
          stdin.puts @inputs unless @inputs.nil?
          stdin.close
          thread.join
          @success = thread.value.success?

          [out.read, err.read]
        end
      end

      def parallel_command
        @full_path || self.class::PARALLEL_COMMAND
      end

      def success?
        @success
      end
    end
    private_constant :Abstract

    class Parallel < Abstract
      PARALLEL_COMMAND = "parallel"
      CPU_OPTION = "-j"
      ADDITIONAL_OPTIONS = ""
    end

    class Xargs < Abstract
      PARALLEL_COMMAND = "xargs"
      CPU_OPTION = "-P"
      ADDITIONAL_OPTIONS = "-I{}"
    end

    class CommandNotSet < StandardError; end
  end
end
