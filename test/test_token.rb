# frozen_string_literal: true

require 'test_helper'
require 'rubylox/scanner'
require 'rubylox/token'

class TestToken  < Minitest::Test
  def test_create_a_token
    token = Rubylox::Token.new(:number, '42', 42, 1)
    assert_equal :number, token.type
  end
end
