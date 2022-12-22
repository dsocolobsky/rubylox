# frozen_string_literal: true

require 'test_helper'
require 'rubylox/scanner'

class TestScanner < Minitest::Test
  def test_scan_simple_tokens
    scanner = Rubylox::Scanner.new('(){},.-+;*!<>/=')
    scanner.scan_tokens

    assert_equal %i[left_paren right_paren left_brace right_brace
    comma dot minus plus semicolon star bang less greater slash equal eof],
                 scanner.tokens.map(&:type)
  end

  def test_scan_two_char_tokens
    scanner = Rubylox::Scanner.new('== != <= >=')
    scanner.scan_tokens

    assert_equal %i[equal_equal bang_equal less_equal greater_equal eof],
                 scanner.tokens.map(&:type)
  end

  def test_scan_two_char_tokens_space_between
    scanner = Rubylox::Scanner.new('= = ! = < = > =')
    scanner.scan_tokens

    assert_equal %i[equal equal bang equal less equal greater equal eof],
                 scanner.tokens.map(&:type)
  end

  def test_scan_strings
    scanner = Rubylox::Scanner.new('"hello" "world"')
    scanner.scan_tokens

    assert_equal %i[string string eof], scanner.tokens.map(&:type)
    assert_equal %w[hello world], scanner.tokens.map(&:literal)[0, 2]
  end

  def test_scan_numbers
    scanner = Rubylox::Scanner.new('123 456')
    scanner.scan_tokens

    assert_equal %i[number number eof], scanner.tokens.map(&:type)
    assert_equal [123, 456], scanner.tokens.map(&:literal)[0, 2]
  end

  def test_scan_identifiers
    scanner = Rubylox::Scanner.new('foo bar')
    scanner.scan_tokens

    assert_equal %i[identifier identifier], scanner.tokens.map(&:type)[0, 2]
  end

  def test_keywords
    scanner = Rubylox::Scanner.new('and class else false for fun if
    nil or print return super this true var while')
    scanner.scan_tokens

    assert_equal %i[and class else false for fun if nil or print return
    super this true var while eof], scanner.tokens.map(&:type)
  end
end
