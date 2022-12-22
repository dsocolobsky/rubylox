module Rubylox
  class AstPrinter
    def print(expression)
      expression.accept(self)
    end

    def visit_grouping_expression(expr)
      parenthesize('group', expr.expression)
    end

    def visit_literal_expression(expr)
      if expr.value.nil?
        'nil'
      else
        expr.value.to_s
      end
    end

    def visit_unary_expression(expr)
      parenthesize(expr.operator.lexeme, expr.right)
    end

    def visit_binary_expression(expr)
      parenthesize(expr.operator.lexeme, expr.left, expr.right)
    end

    def parenthesize(name, *expressions)
      str = "(#{name}"
      expressions.each do |expr|
        str += " #{expr.accept(self)}"
      end
      str += ')'
    end
  end
end
