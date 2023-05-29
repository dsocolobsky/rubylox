module Rubylox
  # Map that stores each variable and its current value
  # Optionally take a parent "enclosing" environment (the parent scope)
  class Environment
    def initialize(enclosing = nil)
      @enclosing = enclosing
      @values = {}
    end

    def define(name, value)
      @values[name] = value
    end

    def get(name)
      key = name.is_a?(Token) ? name.lexeme : name # TODO - this is a bit hacky
      if @values.key?(key)
        @values[key]
      elsif @enclosing # Ask the parent scope if it has the variable
        @enclosing.get(name)
      else
        raise "Undefined variable #{name}"
      end
    end

    def assign(name, value)
      key = name.is_a?(Token) ? name.lexeme : name
      if @values.key?(key)
        @values[key] = value
      elsif @enclosing # Ask the parent scope if it has the variable
        @enclosing.assign(name, value)
      else
        raise "Undefined variable #{name}"
      end
    end
  end
end
