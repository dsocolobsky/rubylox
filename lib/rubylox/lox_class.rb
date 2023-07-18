require 'rubylox/lox_instance'

module Rubylox
  class LoxClass
    def initialize(name)
      @name = name
    end

    attr_reader :name

    def call(interpreter, arguments)
      instance = LoxInstance.new(self)
      instance
    end

    def arity
      0
    end

    def to_s
      @name
    end
  end
end
