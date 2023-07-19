require 'rubylox/lox_instance'

module Rubylox
  class LoxClass
    def initialize(name, methods)
      @name = name
      @methods = methods
    end

    attr_reader :name, :methods

    def find_method(name)
      @methods[name]
    end

    def call(interpreter, arguments)
      LoxInstance.new(self)
    end

    def arity
      0
    end

    def to_s
      @name
    end
  end
end
