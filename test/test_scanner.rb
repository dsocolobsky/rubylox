# frozen_string_literal: true

require 'test_helper'
require 'rubylox/scanner'
require 'rubylox/token'

class TestScanner < Minitest::Test
  def test_scan_simple_tokens
    tokens = scan_program('(){},.-+;*!<>/=')

    assert_types_are(tokens, %i[left_paren right_paren left_brace
    right_brace comma dot minus plus semicolon star bang less greater slash equal])
  end

  def test_scan_two_char_tokens
    scanner = Rubylox::Scanner.new('== != <= >=')
    scanner.scan_tokens

    assert_types_are(scanner.tokens,
                     %i[equal_equal bang_equal less_equal greater_equal])
  end

  def test_scan_two_char_tokens_space_between
    scanner = Rubylox::Scanner.new('= = ! = < = > =')
    scanner.scan_tokens

    assert_types_are(scanner.tokens,
                     %i[equal equal bang equal less equal greater equal])
  end

  def test_scan_strings
    scanner = Rubylox::Scanner.new('"hello" "world"')
    scanner.scan_tokens

    assert_all_have_type(scanner.tokens, :string)
    assert_equal %w[hello world], scanner.tokens.map(&:literal)[0, 2]
  end

  def test_scan_numbers
    scanner = Rubylox::Scanner.new('123 456')
    scanner.scan_tokens

    assert_all_have_type(scanner.tokens, :number)
    assert_equal [123, 456], scanner.tokens.map(&:literal)[0, 2]
  end

  def test_scan_identifiers
    scanner = Rubylox::Scanner.new('foo bar')
    scanner.scan_tokens

    assert_all_have_type(scanner.tokens, :identifier)
  end

  def test_keywords
    scanner = Rubylox::Scanner.new('and class else false for fun if
    nil or print return super this true var while')
    scanner.scan_tokens

    assert_types_are(scanner.tokens, %i[and class else false for fun if
    nil or print return super this true var while])
  end

  def scan_program(source)
    scanner = Rubylox::Scanner.new(source)
    scanner.scan_tokens
    scanner.tokens
  end

  def assert_types_are(tokens, types)
    # Ignore last EOF type
    assert_equal types, tokens.map(&:type)[0...-1]
  end

  def assert_all_have_type(tokens, type)
    tokens.all? { |token| token.type == type }
  end
end
