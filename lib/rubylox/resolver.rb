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
      @current_class = :class_none
    end

    def visit_block_statement(statement)
      begin_scope
      resolve_list_of_statements(statement.statements)
      end_scope
    end

    def visit_class_statement(statement)
      enclosing_class = @current_class
      @current_class = :class
      declare(statement.name)
      define(statement.name)

      unless statement.superclass.nil?
        class_name = statement.name.lexeme
        if statement.superclass.name.lexeme == class_name
          raise "Class #{class_name}: A class can not inherit from itself"
        end

        @current_class = :subclass
        resolve(statement.superclass)
      end

      # if the current class has a superclass then create a new scope and define super in it
      unless statement.superclass.nil?
        begin_scope
        @scopes.last['super'] = true
      end

      begin_scope
      @scopes.last['this'] = true

      statement.methods.each do |method|
        function_type = method.name.lexeme == 'init' ? :initializer : :method
        resolve_function(method, function_type)
      end
      end_scope
      end_scope unless statement.superclass.nil?
      @current_class = enclosing_class
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
      return if statement.value.nil?
      raise error(statement.keyword, 'Cant return a value from an initializer') if @current_function == :initializer

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

    def visit_get_expression(expression)
      resolve(expression.object)
    end

    def visit_set_expression(expression)
      resolve(expression.value)
      resolve(expression.object)
    end

    def visit_super_expression(expression)
      raise 'Cant use super outside of a class' if @current_class == :class_none
      raise 'Cant use super in a class with no superclass' if @current_class != :subclass

      resolve_local(expression, expression.keyword)
    end

    def visit_this_expression(expression)
      raise error(expression.keyword, 'Cant use this outside of a class') if @current_class == :class_none

      resolve_local(expression, expression.keyword)
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