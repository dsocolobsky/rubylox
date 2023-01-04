# frozen_string_literal: true

require 'test_helper'
require 'rubylox/scanner'
require 'rubylox/token'

class TestToken  < Minitest::Test
  def test_create_valid_token_types
    token_if = Rubylox::TokenType.new(:if)
    token_while = Rubylox::TokenType.new(:while)

    assert_equal :if, token_if.type
    assert_equal :while, token_while.type
  end

  def test_create_invalid_token_type
    assert_raises RuntimeError do
      Rubylox::TokenType.new(:invalid)
    end
  end

  def test_create_a_token
    token = Rubylox::Token.new(:number, '42', 42, 1)
    assert_equal :number, token.type
  end
end
