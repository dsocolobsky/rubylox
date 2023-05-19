module Rubylox
  class GroupingExpression
    def initialize(expression)
      @expression = expression
    end

    attr_reader :expression

    def accept(visitor)
      visitor.visit_grouping_expression(self)
    end
  end

  class LiteralExpression
    def initialize(value)
      @value = value
    end

    attr_reader :value

    def accept(visitor)
      visitor.visit_literal_expression(self)
    end
  end

  class VariableExpression
    def initialize(name)
      @name = name
    end

    attr_reader :name

    def accept(visitor)
      visitor.visit_variable_expression(self)
    end
  end

  class UnaryExpression
    def initialize(operator, right)
      @operator = operator
      @right = right
    end

    attr_reader :operator, :right

    def accept(visitor)
      visitor.visit_unary_expression(self)
    end
  end

  class LogicalExpression
    def initialize(left, operator, right)
      @left = left
      @operator = operator
      @right = right
    end

    attr_reader :left, :operator, :right

    def accept(visitor)
      visitor.visit_logical_expression(self)
    end
  end

  class BinaryExpression
    def initialize(left, operator, right)
      @left = left
      @operator = operator
      @right = right
    end

    attr_reader :left, :operator, :right

    def accept(visitor)
      visitor.visit_binary_expression(self)
    end
  end

  class AssignExpression
    def initialize(name, value)
      @name = name
      @value = value
    end

    attr_reader :name, :value

    def accept(visitor)
      visitor.visit_assign_expression(self)
    end
  end
end
