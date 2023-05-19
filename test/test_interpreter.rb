require 'test_helper'
require 'rubylox/scanner'
require 'rubylox/expressions'
require 'rubylox/parser'
require 'rubylox/token'
require 'rubylox/interpreter'
require 'rubylox/environment'

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

  def test_variables
    assert_output(/3.0/) do
      interpret_program('var a = 1; var b = 2; print a+b;')
    end
  end

  def test_variable_assignment
    assert_output(/3.0/) do
      interpret_program('var a = 1; a = 3; print a;')
    end
  end

  def test_variable_scoping
    assert_output(/3.0\n1.0/) do
      interpret_program('var a = 1; { var a = 3; print a; } print a;')
    end
  end

  def test_if_statement
    assert_output(/1.0/) do
      interpret_program('if (true) { print 1; }')
    end
  end

  def test_if_statement_with_else
    assert_output(/2.0/) do
      interpret_program('if (false) { print 1; } else { print 2; }')
    end
  end

  def test_logical_or_true
    assert_output(/true/) do
      interpret_program('print false or true;')
    end
  end

  def test_logical_or_false
    assert_output(/false/) do
      interpret_program('print false or false;')
    end
  end

  def test_logical_and_false
    assert_output(/false/) do
      interpret_program('print false and false;')
    end
  end

  def test_logical_and_true
    assert_output(/true/) do
      interpret_program('print true and true;')
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
