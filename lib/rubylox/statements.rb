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

  class BlockStmt
    def initialize(statements)
      @statements = statements
    end

    attr_reader :statements

    def accept(visitor)
      visitor.visit_block_statement(self)
    end
  end

  class IfStmt
    def initialize(condition, then_branch, else_branch)
      @condition = condition
      @then_branch = then_branch
      @else_branch = else_branch
    end

    attr_reader :condition, :then_branch, :else_branch

    def accept(visitor)
      visitor.visit_if_statement(self)
    end
  end

  class WhileStmt
    def initialize(condition, body)
      @condition = condition
      @body = body
    end

    attr_reader :condition, :body

    def accept(visitor)
      visitor.visit_while_statement(self)
    end
  end

  class FunctionStmt
    def initialize(name, parameters, body)
      @name = name
      @parameters = parameters
      @body = body
    end

    attr_reader :name, :parameters, :body

    def accept(visitor)
      visitor.visit_function_statement(self)
    end
  end

  class ReturnStmt
    def initialize(keyword, value)
      @keyword = keyword
      @value = value
    end

    attr_reader :keyword, :value

    def accept(visitor)
      visitor.visit_return_statement(self)
    end
  end

  # A statement representing a class declaration
  class ClassStmt
    def initialize(name, superclass, methods)
      @name = name
      @superclass = superclass
      @methods = methods
    end

    attr_reader :name, :superclass, :methods

    def accept(visitor)
      visitor.visit_class_statement(self)
    end
  end
end
