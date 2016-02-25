require 'test_helper'

class PostulationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "exists first" do
    p = Postulation.first
    assert_not_nil p
  end



end
