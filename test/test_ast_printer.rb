require 'test_helper'
require 'rubylox/scanner'
require 'rubylox/token'
require 'rubylox/expressions'
require 'rubylox/ast_printer'

class AstPrinterTest < Minitest::Test
  def test_print_grouping
    grouping = Rubylox::GroupingExpression.new(
      Rubylox::LiteralExpression.new(123)
    )

    printer = Rubylox::AstPrinter.new
    assert_equal '(group 123)', printer.print(grouping)
  end

  def test_print_literal
    literal = Rubylox::LiteralExpression.new(123)

    printer = Rubylox::AstPrinter.new
    assert_equal '123', printer.print(literal)
  end

  def test_print_unary_expression
    # create a unary expression
    negation = Rubylox::UnaryExpression.new(
      Rubylox::Token.new(:MINUS, '-', nil, 1),
      Rubylox::LiteralExpression.new(123)
    )

    printer = Rubylox::AstPrinter.new
    assert_equal '(- 123)', printer.print(negation)
  end

  def test_print_binary_expression
    binary = Rubylox::BinaryExpression.new(
      Rubylox::LiteralExpression.new(123),
      Rubylox::Token.new(:STAR, '*', nil, 1),
      Rubylox::LiteralExpression.new(456)
    )

    printer = Rubylox::AstPrinter.new
    assert_equal '(* 123 456)', printer.print(binary)
  end

  def test_print_combined_expressions
    binary = Rubylox::BinaryExpression.new(
      Rubylox::LiteralExpression.new(1),
      Rubylox::Token.new(:PLUS, '+', nil, 1),
      Rubylox::BinaryExpression.new(
        Rubylox::LiteralExpression.new(2),
        Rubylox::Token.new(:STAR, '*', nil, 1),
        Rubylox::LiteralExpression.new(3)
      )
    )

    printer = Rubylox::AstPrinter.new
    assert_equal '(+ 1 (* 2 3))', printer.print(binary)
  end
end
