# frozen_string_literal: true
require 'rubylox/statements'

module Rubylox

  # Transforms a list of tokens into a list of statements
  class Parser

    def initialize(tokens)
      @tokens = tokens
      @current = 0
    end

    def parse
      statements = []
      statements << parse_declaration until at_end?
      statements
    end

    def parse_declaration
      return parse_variable_declaration if match(:var)

      parse_statement
    end

    def parse_variable_declaration
      name = consume(:identifier, 'Expected variable name.')

      initializer = nil
      initializer = expression if match(:equal)

      consume(:semicolon, 'Expect ";" after variable declaration.')
      Rubylox::VariableStmt.new(name, initializer)
    end

    def parse_statement
      return parse_statement_print if match(:print)

      parse_statement_expression
    end

    def parse_statement_print
      value = expression
      consume(:semicolon, "Expect ';' after value.")
      Rubylox::PrintStmt.new(value)
    end

    def parse_statement_expression
      expr = expression
      consume(:semicolon, "Expect ';' after expression.")
      Rubylox::ExpressionStmt.new(expr)
    end

    # The books names this function 'expression' thought I think we can do better
    # Parse assignment for now since it's the lowest-precedence expression we have
    def expression
      parse_assignment
    end

    def parse_assignment
      expr = parse_equality

      if match(:equal)
        equals = previous
        value = parse_assignment

        if expr.is_a?(VariableExpression)
          name = expr.name
          return Rubylox::AssignExpression.new(name, value)
        end

        raise error(equals, 'Invalid assignment target.')
      end

      expr
    end

    def parse_equality
      expr = parse_comparison

      while match(:bang_equal, :equal_equal)
        operator = previous
        right = parse_comparison
        expr = BinaryExpression.new(expr, operator, right)
      end

      expr
    end

    def parse_comparison
      expr = parse_term

      while match(:greater, :greater_equal, :less, :less_equal)
        operator = previous
        right = parse_term
        expr = BinaryExpression.new(expr, operator, right)
      end

      expr
    end

    def parse_term
      expr = parse_factor

      while match(:minus, :plus)
        operator = previous
        right = parse_factor
        expr = BinaryExpression.new(expr, operator, right)
      end

      expr
    end

    def parse_factor
      expr = parse_unary

      while match(:slash, :star)
        operator = previous
        right = parse_unary
        expr = BinaryExpression.new(expr, operator, right)
      end

      expr
    end

    def parse_unary
      if match(:bang, :minus)
        operator = previous
        right = parse_unary
        return UnaryExpression.new(operator, right)
      end

      parse_primary
    end

    def parse_primary
      if match(:false)
        LiteralExpression.new(false)
      elsif match(:true)
        LiteralExpression.new(true)
      elsif match(:nil)
        LiteralExpression.new(nil)
      elsif match(:identifier)
        VariableExpression.new(previous)
      elsif match(:number, :string)
        LiteralExpression.new(previous.literal)
      elsif match(:left_paren)
        expr = expression
        consume(:right_paren, "Expect ')' after expression.")
        GroupingExpression.new(expr)
      else
        raise error(peek, 'Expect expression.')
      end
    end

    def match(*types)
      types.each do |type|
        if peek_is?(type)
          advance
          return true
        end
      end

      false
    end

    def consume(type, message)
      return advance if peek_is?(type)

      raise error(peek, message)
    end

    def error(token, message)
      if token.type == :eof
        report(token.line, 'end', message)
      else
        report(token.line, token.lexeme, message)
      end
    end

    def report(line, where, message)
      "[line #{line}] Error at '#{where}': #{message}"
    end

    def synchronize
      advance

      until at_end? || previous.type == :semicolon
        return if peek.type == :class ||
          peek.type == :fun ||
          peek.type == :var ||
          peek.type == :for ||
          peek.type == :if ||
          peek.type == :while ||
          peek.type == :print ||
          peek.type == :return

        advance
      end
    end

    def peek_is?(type)
      return false if at_end?

      peek.type == type
    end

    def advance
      @current += 1
      previous
    end

    def at_end?
      peek.type == :eof
    end

    def peek
      @tokens[@current]
    end

    def previous
      @tokens[@current - 1]
    end
  end
end
