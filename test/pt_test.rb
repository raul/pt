require 'test_helper'

class PtTes < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::PT::VERSION
  end
end
