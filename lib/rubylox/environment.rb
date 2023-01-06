module Rubylox
  # Map that stores each variable and its current value
  # Optionally take a parent "enclosing" environment (the parent scope)
  class Environment
    def initialize(enclosing = nil)
      @enclosing = enclosing
      @values = {}
    end

    def define(name, value)
      @values[name.lexeme] = value
    end

    def get(name)
      if @values.key?(name.lexeme)
        @values[name.lexeme]
      elsif @enclosing # Ask the parent scope if it has the variable
        @enclosing.get(name)
      else
        raise "Undefined variable #{name}"
      end
    end

    def assign(name, value)
      if @values.key?(name.lexeme)
        @values[name.lexeme] = value
      elsif @enclosing # Ask the parent scope if it has the variable
        @enclosing.assign(name, value)
      else
        raise "Undefined variable #{name}"
      end
    end
  end
end
