module Rubylox
  # Map that stores each variable and its current value
  # Optionally take a parent "enclosing" environment (the parent scope)
  class Environment
    attr_reader :enclosing

    def initialize(enclosing = nil)
      @enclosing = enclosing
      @values = {}
    end

    def define(name, value)
      @values[name] = value
    end

    # Walk up the chain of environments to find the ancestor "distance" away
    def ancestor(distance)
      environment = self
      distance.times do
        environment = environment.enclosing
      end
      environment
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

    # Get the value of a variable at "distance" ancestors away
    def get_at(distance, name)
      ancestor(distance).get(name)
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

    def assign_at(distance, name, value)
      ancestor(distance).assign(name, value)
    end
  end
end
