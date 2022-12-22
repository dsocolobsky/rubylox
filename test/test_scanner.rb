# frozen_string_literal: true

require 'test_helper'
require 'rubylox/scanner'

class TestScanner < Minitest::Test
  def test_scan_simple_tokens
    scanner = Rubylox::Scanner.new('(){},.-+;*!<>/=')
    scanner.scan_tokens

    assert_equal %i[LEFT_PAREN RIGHT_PAREN LEFT_BRACE RIGHT_BRACE
                    COMMA DOT MINUS PLUS SEMICOLON STAR BANG
                    LESS GREATER SLASH EQUAL], scanner.tokens.map(&:type)
  end

  def test_scan_two_char_tokens
    scanner = Rubylox::Scanner.new('== != <= >=')
    scanner.scan_tokens

    assert_equal %i[EQUAL_EQUAL BANG_EQUAL LESS_EQUAL GREATER_EQUAL],
                 scanner.tokens.map(&:type)
  end

  def test_scan_two_char_tokens_space_between
    scanner = Rubylox::Scanner.new('= = ! = < = > =')
    scanner.scan_tokens

    assert_equal %i[EQUAL EQUAL BANG EQUAL LESS EQUAL GREATER EQUAL],
                 scanner.tokens.map(&:type)
  end

  def test_scan_strings
    scanner = Rubylox::Scanner.new('"hello" "world"')
    scanner.scan_tokens

    assert_equal %i[STRING STRING], scanner.tokens.map(&:type)
    assert_equal %w[hello world], scanner.tokens.map(&:literal)
  end

  def test_scan_numbers
    scanner = Rubylox::Scanner.new('123 456')
    scanner.scan_tokens

    assert_equal %i[NUMBER NUMBER], scanner.tokens.map(&:type)
    assert_equal [123, 456], scanner.tokens.map(&:literal)
  end

  def test_scan_identifiers
    scanner = Rubylox::Scanner.new('foo bar')
    scanner.scan_tokens

    assert_equal %i[IDENTIFIER IDENTIFIER], scanner.tokens.map(&:type)
  end

  def test_keywords
    scanner = Rubylox::Scanner.new('and class else false for fun if
    nil or print return super this true var while')
    scanner.scan_tokens

    assert_equal %i[AND CLASS ELSE FALSE FOR FUN IF NIL OR PRINT
                    RETURN SUPER THIS TRUE VAR WHILE], scanner.tokens.map(&:type)
  end
end
