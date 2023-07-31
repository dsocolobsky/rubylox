module Rubylox
  class LoxCallable
    def call
      raise NotImplementedError
    end
  end

  class LoxFunction < LoxCallable
    def initialize(declaration, closure, is_initializer: false)
      super()
      @declaration = declaration
      @closure = closure
      @is_initializer = is_initializer
    end

    def arity
      @declaration.parameters.length
    end

    def call(interpreter, arguments)
      environment = Rubylox::Environment.new(@closure)
      @declaration.parameters.each_with_index do |param, index|
        environment.define(param.lexeme, arguments[index])
      end

      begin
        interpreter.execute_block(@declaration.body.statements, environment)
      rescue ReturnException => e
        return functions_object if @is_initializer

        return e.value
      end

      if @is_initializer
        functions_object
      end
    end

    def bind(instance)
      environment = Rubylox::Environment.new(@closure)
      environment.define('this', instance)
      LoxFunction.new(@declaration, environment, is_initializer: @is_initializer)
    end

    def functions_object
      @closure.get_at(0, 'this')
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
