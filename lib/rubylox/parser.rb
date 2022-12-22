module Rubylox
  class Parser
    def parse(expression)
      raise NotImplementedError
    end

    def visit_grouping_expression(expr)
      raise NotImplementedError
    end

    def visit_literal_expression(expr)
      raise NotImplementedError
    end

    def visit_unary_expression(expr)
      raise NotImplementedError
    end

    def visit_binary_expression(expr)
      raise NotImplementedError
    end
  end
end
