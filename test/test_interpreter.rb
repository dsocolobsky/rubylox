require 'test_helper'
require 'rubylox/scanner'
require 'rubylox/expressions'
require 'rubylox/parser'
require 'rubylox/token'
require 'rubylox/interpreter'

class TestInterpreter < Minitest::Test
  def test_number
    out = interpret_program('42')

    assert_equal "42.0", out
  end

  def test_addition
    out = interpret_program('5 + 2')

    assert_equal "7.0", out
  end

  def test_mathematical_operations
    out = interpret_program('5 + 2 * 3 - 1')

    assert_equal "10.0", out
  end

  def test_division
    out = interpret_program('5 / 2')

    assert_equal "2.5", out
  end

  def interpret_program(source)
    tokens = Rubylox::Scanner.new(source).scan_tokens
    parser = Rubylox::Parser.new(tokens)
    expression = parser.parse(tokens)
    interpreter = Rubylox::Interpreter.new
    interpreter.interpret(expression)
  end
end
