module Rubylox
  # Map that stores each variable and its current value
  class Environment
    def initialize
      @values = {}
    end

    def define(name, value)
      @values[name.lexeme] = value
    end

    def get(name)
      if @values.key?(name.lexeme)
        @values[name.lexeme]
      else
        raise "Undefined variable #{name}"
      end
    end
  end
end
