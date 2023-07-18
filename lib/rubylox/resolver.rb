# frozen_string_literal: true
module Rubylox
  class Resolver
    def initialize(interpreter)
      @interpreter = interpreter
      # This is a stack of Hashmap<String,Boolean>
      # Each HashMap representing a single scope.
      # When resolving a variable, if we can not find it in a local scope
      # then we assume it must be global
      @scopes = []
      @current_function = :function_none
    end

    def visit_block_statement(statement)
      begin_scope
      resolve_list_of_statements(statement.statements)
      end_scope
    end

    def visit_class_statement(statement)
      declare(statement.name)
      define(statement.name)
    end

    def visit_expression_statement(statement)
      resolve(statement.expression)
    end

    def visit_function_statement(statement)
      declare(statement.name)
      define(statement.name)
      resolve_function(statement, :function)
    end

    def visit_if_statement(statement)
      resolve(statement.condition)
      resolve(statement.then_branch)
      resolve(statement.else_branch) unless statement.else_branch.nil?
    end

    def visit_print_statement(statement)
      resolve(statement.expression)
    end

    def visit_return_statement(statement)
      raise error(statement.keyword, 'Cant return from top-level code') if @current_function == :function_none

      resolve(statement.value) unless statement.value.nil?
    end

    def visit_while_statement(statement)
      resolve(statement.condition)
      resolve(statement.body)
    end

    def visit_variable_statement(statement)
      declare(statement.name)
      resolve(statement.initializer) unless statement.initializer.nil?
      define(statement.name)
    end

    def visit_variable_expression(expression)
      if !@scopes.empty? && (@scopes.last[expression.name.lexeme] == false)
        raise error(expression.name, 'Cant read local variable in its own initializer')
      end

      resolve_local(expression, expression.name)
    end

    def visit_assignment_expression(expression)
      resolve(expression.value)
      resolve_local(expression, expression.name)
    end

    def visit_binary_expression(expression)
      resolve(expression.left)
      resolve(expression.right)
    end

    def visit_call_expression(expression)
      resolve(expression.callee)
      expression.arguments.each do |argument|
        resolve(argument)
      end
    end

    def visit_grouping_expression(expression)
      resolve(expression.expression)
    end

    def visit_literal_expression(_expression)
      # Doesn't have any variables, so do nothing
    end

    def visit_logical_expression(expression)
      resolve(expression.left)
      resolve(expression.right)
    end

    def visit_unary_expression(expression)
      resolve(expression.right)
    end

    def resolve_list_of_statements(statements)
      statements.each do |statement|
        resolve(statement)
      end
    end

    def resolve_function(function, function_type)
      enclosing_function = @current_function
      @current_function = function_type

      begin_scope
      function.parameters.each do |parameter|
        declare(parameter)
        define(parameter)
      end
      resolve_list_of_statements(function.body.statements)
      end_scope

      @current_function = enclosing_function
    end

    def resolve(statement)
      statement.accept(self)
    end

    def resolve_expression(expression)
      expression.accept(self)
    end

    def resolve_local(expression, name)
      i = 0
      @scopes.reverse_each do |scope|
        if scope.key?(name.lexeme)
          @interpreter.resolve(expression, i)
          break
        end
        i += 1
      end
    end

    def begin_scope
      @scopes << ({})
    end

    def end_scope
      @scopes.pop
    end

    def declare(name)
      return if @scopes.empty?

      scope = @scopes.last
      if scope.key?(name.lexeme)
        raise error(name, 'Already a variable with this name in this scope')
      else
        @scopes.last[name.lexeme] = false unless @scopes.empty?
      end
    end

    def define(name)
      @scopes.last[name.lexeme] = true unless @scopes.empty?
    end
  end
end