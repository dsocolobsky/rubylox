module Rubylox
  class LoxCallable
    def call
      raise NotImplementedError
    end
  end

  class LoxFunction < LoxCallable
    @declaration = nil

    def arity
      @declaration.parameters.length
    end

    def initialize(declaration)
      @declaration = declaration
    end

    def call(interpreter, arguments)
      environment = Rubylox::Environment.new(interpreter.globals)
      @declaration.parameters.each_with_index do |param, index|
        environment.define(param.lexeme, arguments[index])
      end

      begin
        interpreter.execute_block(@declaration.body.statements, environment)
      rescue ReturnException => e
        return e.value
      end

      nil
    end
  end

  class ReturnException < StandardError
    attr_reader :value

    def initialize(value, message = nil)
      super(message)
      @value = value
    end
  end
end
