module KOHMM
  # Name space for output formatter classes.
  # Each formatters shall respond to `#format' with two arguments.
  # The first argument is a `KOHMM::Result' instance, and the second
  # is an IO object or any instance responding `#<<' to get the output.
  module OutputFormatter
    extend Autoload

    autoload :SimpleTabularFormatter
    autoload :MultiHitTabularFormatter
    autoload :HitDetailFormatter
  end
end
