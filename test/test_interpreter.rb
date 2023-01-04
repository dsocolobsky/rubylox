require 'test_helper'
require 'rubylox/scanner'
require 'rubylox/expressions'
require 'rubylox/parser'
require 'rubylox/token'
require 'rubylox/interpreter'

class TestInterpreter < Minitest::Test
  def test_number
    assert_output(/42.0/) do
      interpret_program('print 42;')
    end
  end

  def test_addition
    assert_output(/7.0/) do
      interpret_program('print 5 + 2;')
    end
  end

  def test_mathematical_operations
    assert_output(/10.0/) do
      interpret_program('print 5 + 2 * 3 - 1;')
    end
  end

  def test_division
    assert_output(/2.5/) do
      interpret_program('print 5/2;')
    end
  end

  def interpret_program(source)
    tokens = Rubylox::Scanner.new(source).scan_tokens
    parser = Rubylox::Parser.new(tokens)
    expression = parser.parse
    interpreter = Rubylox::Interpreter.new
    interpreter.interpret(expression)
  end
end
