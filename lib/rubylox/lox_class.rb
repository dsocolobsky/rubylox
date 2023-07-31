require 'rubylox/lox_instance'

module Rubylox
  class LoxClass
    def initialize(name, methods, superclass)
      @name = name
      @methods = methods
      @superclass = superclass
    end

    attr_reader :name, :methods

    def find_method(name)
      if @methods.key?(name)
        @methods[name]
      elsif @superclass
        @superclass.find_method(name)
      end
    end

    def call(interpreter, arguments)
      instance = LoxInstance.new(self)
      initializer = find_method('init')
      initializer&.bind(instance)&.(interpreter, arguments)
      instance
    end

    def arity
      initializer = find_method('init')
      initializer&.arity || 0
    end

    def to_s
      @name
    end
  end
end
