require 'test_helper'
require 'rubylox/scanner'
require 'rubylox/expressions'
require 'rubylox/parser'

class TestParser < Minitest::Test

  def test_parse_number
    tokens = Rubylox::Scanner.new('42').scan_tokens
    parser = Rubylox::Parser.new(tokens)

    res = parser.parse(tokens)
    assert_instance_of Rubylox::LiteralExpression, res
    assert_equal 42.0, res.value
  end

  def test_parse_decimal_number
    tokens = Rubylox::Scanner.new('3.14').scan_tokens
    parser = Rubylox::Parser.new(tokens)

    res = parser.parse(tokens)
    assert_instance_of Rubylox::LiteralExpression, res
    assert_equal 3.14, res.value
  end

  def test_parse_unary
    tokens = Rubylox::Scanner.new('!1').scan_tokens
    parser = Rubylox::Parser.new(tokens)

    res = parser.parse(tokens)
    assert_instance_of Rubylox::UnaryExpression, res
    assert_equal :bang, res.operator.type
    assert_equal 1.0, res.right.value
  end

  def test_parse_double_negation
    tokens = Rubylox::Scanner.new('!!bar').scan_tokens
    parser = Rubylox::Parser.new(tokens)

    neg_neg_bar = parser.parse(tokens)
    assert_instance_of Rubylox::UnaryExpression, neg_neg_bar
    assert_equal :bang, neg_neg_bar.operator.type

    neg_bar = neg_neg_bar.right
    assert_instance_of Rubylox::UnaryExpression, neg_bar
    assert_equal :bang, neg_bar.operator.type
    assert_equal 'bar', neg_bar.right.value
  end

  def test_parse_term
    tokens = Rubylox::Scanner.new('1 + 2 + 3').scan_tokens
    parser = Rubylox::Parser.new(tokens)

    sum = parser.parse(tokens)
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
    tokens = Rubylox::Scanner.new('2 * 3 * 9').scan_tokens
    parser = Rubylox::Parser.new(tokens)

    multiplication = parser.parse(tokens)
    assert_instance_of Rubylox::BinaryExpression, multiplication
    assert_equal :star, multiplication.operator.type
    assert_equal 9.0, multiplication.right.value

    two_times_three = multiplication.left
    assert_instance_of Rubylox::BinaryExpression, two_times_three
    assert_equal 2.0, two_times_three.left.value
    assert_equal :star, two_times_three.operator.type
    assert_equal 3.0,two_times_three.right.value
  end

  def test_parse_grouping
    tokens = Rubylox::Scanner.new('(42)').scan_tokens
    parser = Rubylox::Parser.new(tokens)

    res = parser.parse(tokens)
    assert_instance_of Rubylox::GroupingExpression, res
    assert_equal 42.0, res.expression.value
  end

  def test_parse_grouping_complex
    tokens = Rubylox::Scanner.new('(4 - 3)').scan_tokens
    parser = Rubylox::Parser.new(tokens)

    res = parser.parse(tokens)
    assert_instance_of Rubylox::GroupingExpression, res
    inner = res.expression
    assert_instance_of Rubylox::BinaryExpression, inner
    assert_equal 4.0, inner.left.value
    assert_equal :minus, inner.operator.type
    assert_equal 3.0, inner.right.value
  end

  def test_parse_arithmetic
    tokens = Rubylox::Scanner.new('1 + 2 * 3').scan_tokens
    parser = Rubylox::Parser.new(tokens)

    res = parser.parse(tokens)
    assert_instance_of Rubylox::BinaryExpression, res
    assert_equal :plus, res.operator.type
    assert_equal 1.0, res.left.value
    assert_equal 6.0, res.right.value
  end
end
