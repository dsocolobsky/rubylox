module Rubylox
  class Interpreter

    def initialize
      @environment = Rubylox::Environment.new
    end

    def interpret(statements)
      statements.each do |statement|
        execute(statement)
      end
    end

    def execute_block(statements, environment)
      parent = @environment

      begin
        @environment = environment
        statements.each do |statement|
          execute(statement)
        end
      ensure
        @environment = parent
      end
    end

    def execute(statement)
      statement.accept(self)
    end

    def visit_expression_statement(stmt)
      evaluate(stmt.expression)
    end

    def visit_print_statement(stmt)
      value = evaluate(stmt.expression)
      puts value.to_s
    end

    def visit_variable_statement(stmt)
      value = nil
      value = evaluate(stmt.initializer) if stmt.initializer
      @environment.define(stmt.name, value)
    end

    def visit_block_statement(stmt)
      execute_block(stmt.statements, Environment.new(@environment))
    end

    def visit_if_statement(stmt)
      if is_truthy(evaluate(stmt.condition))
        execute(stmt.then_branch)
      elsif stmt.else_branch
        execute(stmt.else_branch)
      end
    end

    def visit_function_statement(stmt)
      raise NotImplementedError
    end

    def visit_literal_expression(expr)
      expr.value
    end

    def visit_variable_expression(expr)
      @environment.get(expr.name)
    end

    def visit_assign_expression(expr)
      value = evaluate(expr.value)
      @environment.assign(expr.name, value)
      value
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

    def visit_logical_expression(expr)
      left = evaluate(expr.left)

      if expr.operator.type == :or
        return left if is_truthy(left)
      else
        return left unless is_truthy(left)
      end

      evaluate(expr.right)
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

    def visit_while_statement(expr)
      execute(expr.body) while is_truthy(evaluate(expr.condition))
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