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
      return parse_class_declaration if match(:class)
      return parse_function_declaration('function') if match(:fun)
      return parse_variable_declaration if match(:var)

      parse_statement
    end

    def parse_class_declaration
      name = consume(:identifier, 'Expect class name.')

      consume(:left_brace, "Expect '{' before class body.")

      methods = []
      methods << parse_function_declaration('method') until match(:right_brace) || at_end?

      superclass = nil # This will change later
      Rubylox::ClassStmt.new(name, superclass, methods)
    end

    def parse_function_declaration(kind)
      name = consume(:identifier, "Expect #{kind} name.")
      consume(:left_paren, "Expect '(' after #{kind} name.")

      parameters = []
      unless peek_is?(:right_paren)
        loop do
          raise error(peek, 'Can not have more than 255 parameters') if parameters.length >= 255

          parameters.push(consume(:identifier, 'Expect parameter name.'))
          break unless match(:comma)
        end
      end
      consume(:right_paren, "Expect ')' after parameters.")

      consume(:left_brace, "Expect '{' before #{kind} body.")
      body = parse_statement_block

      Rubylox::FunctionStmt.new(name, parameters, body)
    end

    def parse_variable_declaration
      name = consume(:identifier, 'Expected variable name.')

      initializer = nil
      initializer = expression if match(:equal)

      consume(:semicolon, 'Expect ";" after variable declaration.')
      Rubylox::VariableStmt.new(name, initializer)
    end

    def parse_statement
      return parse_statement_if if match(:if)
      return parse_statement_print if match(:print)
      return parse_statement_return if match(:return)
      return parse_statement_while if match(:while)
      return parse_statement_block if match(:left_brace)

      parse_statement_expression
    end

    def parse_statement_if
      consume(:left_paren, "Expect '(' after 'if'.")
      condition = expression
      consume(:right_paren, "Expect ')' after if condition.")

      then_branch = parse_statement
      else_branch = parse_statement if match(:else)

      Rubylox::IfStmt.new(condition, then_branch, else_branch)
    end

    def parse_statement_print
      value = expression
      consume(:semicolon, "Expect ';' after value.")
      Rubylox::PrintStmt.new(value)
    end

    def parse_statement_return
      keyword = previous
      value = nil
      # parse the return expression unless we see a semicolon in which case there is none
      value = expression unless peek_is?(:semicolon)
      consume(:semicolon, "Expect ';' after return value.")
      Rubylox::ReturnStmt.new(keyword, value)
    end

    def parse_statement_expression
      expr = expression
      consume(:semicolon, "Expect ';' after expression.")
      Rubylox::ExpressionStmt.new(expr)
    end

    def parse_statement_block
      statements = []

      while !peek_is?(:right_brace) && !at_end?
        statements << parse_declaration
      end

      consume(:right_brace, "Expect '}' after block.")
      BlockStmt.new(statements)
    end

    def parse_statement_while
      consume(:left_paren, "Expect '(' after 'while'.")
      condition = expression
      consume(:right_paren, "Expect ')' after condition.")
      body = parse_statement

      Rubylox::WhileStmt.new(condition, body)
    end

    # The books names this function 'expression' thought I think we can do better
    # Parse assignment for now since it's the lowest-precedence expression we have
    def expression
      parse_assignment
    end

    def parse_assignment
      expr = parse_or

      if match(:equal)
        equals = previous
        value = parse_assignment

        case expr
        when VariableExpression
          name = expr.name
          return Rubylox::AssignmentExpression.new(name, value)
        when GetExpression
          get = expr
          return Rubylox::SetExpression.new(get.object, get.name, value)
        else
          raise error(equals, 'Invalid assignment target.')
        end
      end

      expr
    end

    def parse_or
      expr = parse_and

      while match(:or)
        operator = previous
        right = parse_and
        expr = LogicalExpression.new(expr, operator, right)
      end

      expr
    end

    def parse_and
      expr = parse_equality

      while match(:and)
        operator = previous
        right = parse_equality
        expr = LogicalExpression.new(expr, operator, right)
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

      parse_call
    end

    def parse_call
      # Parse a call to a func: primary(arguments?)
      expr = parse_primary

      loop do
        if match(:left_paren)
          expr = finish_call(expr)
        elsif match(:dot)
          name = consume(:identifier, "Expect property name after '.'.")
          expr = GetExpression.new(expr, name)
        else
          break
        end
      end

      expr
    end

    def finish_call(callee)
      # Parse the input arguments for a call and generate the CallExpression object
      arguments = []
      unless peek_is?(:right_paren)
        loop do
          raise error(peek, 'Can not have more than 255 arguments') if arguments.length >= 255

          arguments.push(expression)
          break unless match(:comma)
        end
      end

      paren = consume(:right_paren, 'Expect ) after arguments')
      CallExpression.new(callee, paren, arguments)
    end

    def parse_primary
      return LiteralExpression.new(false) if match(:false)
      return LiteralExpression.new(true) if match(:true)
      return LiteralExpression.new(nil) if match(:nil)
      return LiteralExpression.new(previous.literal) if match(:number, :string)
      return ThisExpression.new(previous) if match(:this)
      return VariableExpression.new(previous) if match(:identifier)

      if match(:left_paren)
        expr = expression
        consume(:right_paren, "Expect ')' after expression.")
        return GroupingExpression.new(expr)
      end

      raise error(peek, 'Expect expression.')
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
