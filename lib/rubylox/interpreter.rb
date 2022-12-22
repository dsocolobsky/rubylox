module Rubylox
  class Interpreter

    def interpret(expr)
      evaluate(expr).to_s
    end

    def visit_literal_expression(expr)
      expr.value
    end

    def visit_grouping_expression(expr)
      evaluate(expr.expression)
    end

    def visit_unary_expression(expr)
      right = evaluate(expr.right)

      case expr.operator.type
      when :minus
        -right
      when :bang
        !is_truthy(right)
      else
        raise "Unknown unary operator: #{expr.operator.type}"
      end
    end

    def visit_binary_expression(expr)
      left = evaluate(expr.left)
      right = evaluate(expr.right)

      case expr.operator.type
      when :minus
        left - right
      when :plus
        left + right
      when :slash
        left / right
      when :star
        left * right
      when :greater
        left > right
      when :greater_equal
        left >= right
      when :less
        left < right
      when :less_equal
        left <= right
      when :equal_equal
        left == right
      when :bang_equal
        left != right
      else
        raise "Unknown binary operator: #{expr.operator.type}"
      end
    end

    def evaluate(expr)
      expr.accept(self)
    end

    def is_truthy(object)
      if object.nil?
        false
      else
        object != false
      end
    end
  end
end