module KofamScan
  # Base class for output formatter classes.
  # Each formatters shall respond to `#format' with two arguments.
  # The first argument is a `KofamScan::Result' instance, and the second
  # is an IO object or any instance responding `#<<' to get the output.
  class OutputFormatter
    extend Autoload

    autoload :SimpleTabularFormatter
    autoload :MultiHitTabularFormatter
    autoload :HitDetailFormatter
    autoload :TabularAllHitFormatter

    attr_accessor :report_unannotated
  end
end
