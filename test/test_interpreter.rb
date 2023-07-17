require 'test_helper'
require 'rubylox/scanner'
require 'rubylox/expressions'
require 'rubylox/parser'
require 'rubylox/token'
require 'rubylox/resolver'
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

  def test_variable_simple
    assert_output(/3.0/) do
      interpret_program('var a = 3; print a;')
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

  def test_while_loop
    assert_output(/1.0\n2.0\n3.0\n4.0\n5.0/) do
      interpret_program('var a = 1; while (a < 6) { print a; a = a + 1; }')
    end
  end

  def test_function_call_clock
    # Replace Time.now with a lambda that returns the fixed time
    Time.stub :now, -> { Time.at(3600) } do
      assert_output(/3600.0/) do
        interpret_program('print clock();')
      end
    end
  end

  def test_define_simple_function
    assert_output(/3.0/) do
      interpret_program('fun foo() { print 3; } foo();')
    end
  end

  def test_define_function_with_parameters
    assert_output(/3.0/) do
      code = <<-CODE
        fun add(a, b) {
          print a + b;
        }
        add(1, 2);
      CODE
      interpret_program(code)
    end
  end

  def test_function_fibonacci
    assert_output(/55.0/) do
      code = <<-CODE
        fun fib(n) {
          if (n <= 1) return n;
          return fib(n - 2) + fib(n - 1);
        }
        print fib(10);
      CODE
      interpret_program(code)
    end
  end

  def test_closures_counter
    assert_output(/2.0/) do
      code = <<-CODE
        fun makeCounter() {
          var i = 0;
          fun count() {
            i = i + 1;
            print i;
          }

          return count;
        }

        var counter = makeCounter();
        counter(); // "1".
        counter(); // "2".
      CODE
      interpret_program(code)
    end
  end

  def interpret_program(source)
    tokens = Rubylox::Scanner.new(source).scan_tokens
    parser = Rubylox::Parser.new(tokens)
    expression = parser.parse
    interpreter = Rubylox::Interpreter.new
    resolver = Rubylox::Resolver.new(interpreter)
    resolver.resolve_list_of_statements(expression)
    interpreter.interpret(expression)
  end
end
