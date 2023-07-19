require 'rubylox/lox_function'
require 'rubylox/lox_class'

module Rubylox
  class Interpreter

    attr_reader :globals, :locals

    def initialize
      @globals = Rubylox::Environment.new
      @locals = {}

      @globals.define('clock', Class.new(LoxCallable) do
        def self.arity
          0
        end

        def self.call(interpreter, arguments)
          Time.now.utc.to_f
        end

        def self.to_s
          '<native fn>'
        end
      end)

      @environment = @globals
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

    def resolve(expression, depth)
      @locals[expression] = depth
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
      @environment.define(stmt.name.lexeme, value)
    end

    def visit_block_statement(stmt)
      execute_block(stmt.statements, Environment.new(@environment))
    end

    def visit_class_statement(stmt)
      @environment.define(stmt.name.lexeme, nil)

      methods = {}
      stmt.methods.each do |method|
        function = LoxFunction.new(method, @environment)
        methods[method.name.lexeme] = function
      end

      kclass = LoxClass.new(stmt.name.lexeme, methods)
      @environment.assign(stmt.name, kclass)
    end

    def visit_if_statement(stmt)
      if is_truthy(evaluate(stmt.condition))
        execute(stmt.then_branch)
      elsif stmt.else_branch
        execute(stmt.else_branch)
      end
    end

    def visit_function_statement(stmt)
      function = LoxFunction.new(stmt, @environment)
      @environment.define(stmt.name.lexeme, function)
      nil
    end

    def visit_return_statement(stmt)
      value = nil
      value = evaluate(stmt.value) if stmt.value
      raise ReturnException.new(value, nil)
    end

    def visit_literal_expression(expr)
      expr.value
    end

    def visit_variable_expression(expr)
      lookup_variable(expr.name, expr)
    end

    def lookup_variable(name, expr)
      distance = @locals[expr]
      if distance
        @environment.get_at(distance, name.lexeme)
      else
        @globals.get(name)
      end
    end

    def visit_assignment_expression(expr)
      value = evaluate(expr.value)

      distance = @locals[expr]
      if distance
        @environment.assign_at(distance, expr.name, value)
      else
        @globals.assign(expr.name, value)
      end

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

    def visit_call_expression(expression)
      # First we evaluate the expression for the callee which usually is just an identifier
      # but could be anything really
      callee = evaluate(expression.callee)

      # Now we evaluate each of the arguments in order
      arguments = []
      expression.arguments.each do |argument|
        arguments.push(evaluate(argument))
      end

      raise 'Can only call functions and classes' unless callee.respond_to?(:call)

      function = callee
      raise 'Wrong number of arguments' if arguments.length != function.arity

      function.call(self, arguments)
    end

    def visit_get_expression(expression)
      object = evaluate(expression.object)
      if object.is_a?(LoxInstance)
        object.get(expression.name)
      else
        raise 'Only instances have properties'
      end
    end

    def visit_set_expression(expression)
      object = evaluate(expression.object)
      raise 'Only instances have fields' unless object.is_a?(LoxInstance)

      value = evaluate(expression.value)
      object.set(expression.name, value)
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