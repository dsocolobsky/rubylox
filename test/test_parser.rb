require 'test_helper'
require 'rubylox/scanner'
require 'rubylox/expressions'
require 'rubylox/parser'
require 'rubylox/token'

class TestParser < Minitest::Test
  def test_parse_number
    number = scan_program('42;')

    assert_instance_of Rubylox::LiteralExpression, number
    assert_equal 42.0, number.value
  end

  def test_parse_decimal_number
    number = scan_program('3.14;')

    assert_instance_of Rubylox::LiteralExpression, number
    assert_equal 3.14, number.value
  end

  def test_parse_unary
    neg_one = scan_program('!1;')

    assert_instance_of Rubylox::UnaryExpression, neg_one
    assert_equal :bang, neg_one.operator.type
    assert_equal 1.0, neg_one.right.value
  end

  def test_parse_double_negation
    neg_neg_bar = scan_program('!!bar;')
    assert_instance_of Rubylox::UnaryExpression, neg_neg_bar
    assert_equal :bang, neg_neg_bar.operator.type

    neg_bar = neg_neg_bar.right
    assert_instance_of Rubylox::UnaryExpression, neg_bar
    assert_equal :bang, neg_bar.operator.type

    assert_instance_of Rubylox::VariableExpression, neg_bar.right
    assert_equal 'bar', neg_bar.right.name.lexeme
  end

  def test_parse_term
    sum = scan_program('1 + 2 + 3;')
    assert_instance_of Rubylox::BinaryExpression, sum
    assert_equal :plus, sum.operator.type
    assert_equal 3.0, sum.right.value

    one_plus_two = sum.left
    assert_instance_of Rubylox::BinaryExpression, one_plus_two
    assert_equal :plus, one_plus_two.operator.type
    assert_equal 1.0, one_plus_two.left.value
    assert_equal 2.0, one_plus_two.right.value
  end

  def test_parse_factor
    multiplication = scan_program('2 * 3 * 9;')
    assert_instance_of Rubylox::BinaryExpression, multiplication
    assert_equal :star, multiplication.operator.type
    assert_equal 9.0, multiplication.right.value

    two_times_three = multiplication.left
    assert_instance_of Rubylox::BinaryExpression, two_times_three
    assert_equal 2.0, two_times_three.left.value
    assert_equal :star, two_times_three.operator.type
    assert_equal 3.0,two_times_three.right.value
  end

  def test_parse_mixed_operations
    one_plus_two_times_three = scan_program('1 + 2 * 3;')

    assert_instance_of Rubylox::BinaryExpression, one_plus_two_times_three
    assert_equal :plus, one_plus_two_times_three.operator.type

    left = one_plus_two_times_three.left
    assert_instance_of Rubylox::LiteralExpression, left
    assert_equal 1.0, left.value

    right = one_plus_two_times_three.right
    assert_instance_of Rubylox::BinaryExpression, right
    assert_equal :star, right.operator.type
    assert_equal 2.0, right.left.value
    assert_equal 3.0, right.right.value
  end

  def test_parse_grouping
    group = scan_program('(4 - 3);')

    assert_instance_of Rubylox::GroupingExpression, group
    inner = group.expression
    assert_instance_of Rubylox::BinaryExpression, inner
    assert_equal 4.0, inner.left.value
    assert_equal :minus, inner.operator.type
    assert_equal 3.0, inner.right.value
  end

  def test_parse_logical_expressions
    expression = scan_program('true and false;')
    assert_instance_of Rubylox::LogicalExpression, expression
    assert_equal :and, expression.operator.type

    left = expression.left
    assert_instance_of Rubylox::LiteralExpression, left
    assert_equal true, left.value

    right = expression.right
    assert_instance_of Rubylox::LiteralExpression, right
    assert_equal false, right.value
  end

  def scan_program(source)
    tokens = Rubylox::Scanner.new(source).scan_tokens
    parser = Rubylox::Parser.new(tokens)
    parser.parse[0].expression
  end
end
