# frozen_string_literal: true

require 'open3'
autoload :Shellwords, 'shellwords'

module KOHMM
  module ParallelCommand
    class << self
      def create(parallel_command = nil)
        if parallel_command
          if parallel_command =~ /\//
            return create_from_parallel_command_path(parallel_command)
          else
            return create_from_parallel_command_name(parallel_command)
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

      private

      def create_from_parallel_command_name(command)
        const_get(command.capitalize).new
      end

      def create_from_parallel_command_path(path)
        command = File.basename(path, '.*')
        const_get(command.capitalize).new(full_path: path)
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

      def build_command
        raise CommandNotSet unless command

        result = [parallel_command, cpu_option, cpu, additional_options]
        command_arr = command.kind_of?(Array) ? command : Shellwords.split(command)
        result.concat(command_arr)
        result.map(&:to_s)
      end

      def exec
        Open3.popen3(*build_command) do |stdin, out, err, thread|
          stdin.puts @inputs if @inputs
          stdin.close
          thread.join
          @success = thread.value.success?

          [out.read, err.read]
        end
      end

      def parallel_command
        @full_path || default_parallel_command
      end

      def success?
        @success
      end

      private

      def default_parallel_command
        raise NotImplementedError
      end

      def cpu_option
        raise NotImplementedError
      end

      def additional_options
        raise NotImplementedError
      end
    end
    private_constant :Abstract

    class Parallel < Abstract
      def default_parallel_command
        "parallel"
      end

      def cpu_option
        "-j"
      end

      def additional_options
        "--quote"
      end
    end

    class Xargs < Abstract
      def default_parallel_command
        "xargs"
      end

      def cpu_option
        "-P"
      end

      def additional_options
        "-I{}"
      end
    end

    class CommandNotSet < StandardError; end
  end
end
