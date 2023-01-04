# frozen_string_literal: true

require 'test_helper'
require 'rubylox/scanner'
require 'rubylox/statements'

class TestToken  < Minitest::Test
  def test_pass
    assert_equal 2, 2
  end
end
