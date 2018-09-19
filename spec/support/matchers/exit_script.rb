require 'rspec/expectations'

RSpec::Matchers.define :exit_script do
  supports_block_expectations

  def expects_call_stack_jump?
    true
  end

  match do |block|
    @actual_status = nil
    begin
      block.call
    rescue SystemExit => e
      @actual_status = e.status
    end

    # when SystemExit not raised, match fails
    return false unless @actual_status
    # when expected_status is not set, match successes
    return true  unless @expected_status

    @expected_status.include?(@actual_status)
  end

  chain :with_exit_status do |*status|
    @expected_status = status
  end

  chain :successfully do
    @expected_status = [0]
  end

  chain :unsuccessfully do
    @expected_status = 1..255
  end

  description do
    desc = "exit the script"
    desc << " with exit status #{@expected_status.join(',')}" if @expected_status
    desc
  end

  failure_message do
    return "Expected to exit script, but did not exit" unless @actual_status

    expected = @expected_status
    expected_str = expected.respond_to?(:join) ? expected.join(',') : expected.to_s

    "Expected exit status #{expected_str}, got #{@actual_status}"
  end
end
