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
end