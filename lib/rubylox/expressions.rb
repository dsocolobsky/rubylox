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

  class AssignmentExpression
    def initialize(name, value)
      @name = name
      @value = value
    end

    attr_reader :name, :value

    def accept(visitor)
      visitor.visit_assignment_expression(self)
    end
  end

  class CallExpression
    def initialize(callee, paren, arguments)
      @callee = callee
      @paren = paren
      @arguments = arguments
    end

    attr_reader :callee, :paren, :arguments

    def accept(visitor)
      visitor.visit_call_expression(self)
    end
  end

  class GetExpression
    def initialize(object, name)
      @object = object
      @name = name
    end

    attr_reader :object, :name

    def accept(visitor)
      visitor.visit_get_expression(self)
    end
  end

  class SetExpression
    def initialize(object, name, value)
      @object = object
      @name = name
      @value = value
    end

    attr_reader :object, :name, :value

    def accept(visitor)
      visitor.visit_set_expression(self)
    end
  end

  class ThisExpression
    def initialize(keyword)
      @keyword = keyword
    end

    attr_reader :keyword

    def accept(visitor)
      visitor.visit_this_expression(self)
    end
  end

  class SuperExpression
    def initialize(keyword, method)
      @keyword = keyword
      @method = method
    end

    attr_reader :keyword, :method

    def accept(visitor)
      visitor.visit_super_expression(self)
    end
  end
end
