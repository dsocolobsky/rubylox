# frozen_string_literal: true
module Rubylox
  class ExpressionStmt
    def initialize(expression)
      @expression = expression
    end

    attr_reader :expression

    def accept(visitor)
      visitor.visit_expression_statement(self)
    end
  end

  class PrintStmt
    def initialize(expression)
      @expression = expression
    end

    attr_reader :expression

    def accept(visitor)
      visitor.visit_print_statement(self)
    end
  end

  class VariableStmt
    def initialize(name, initializer)
      @name = name
      @initializer = initializer
    end

    attr_reader :name, :initializer

    def accept(visitor)
      visitor.visit_variable_statement(self)
    end
  end

  class FunctionStmt
    def initialize(name, params, body)
      @name = name
      @params = params
      @body = body
    end

    attr_reader :name, :params, :body

    def accept(visitor)
      visitor.visit_function_statement(self)
    end
  end
end
