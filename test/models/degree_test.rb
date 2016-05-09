require 'test_helper'

class DegreeTest < ActiveSupport::TestCase
  test "the truth" do
    assert_equal 2, Degree.count
  end
  test "no title" do
    degree = Degree.first.update(:title => nil)
    assert_not degree
  end
  test "no user_id" do
    degree = Degree.first.update(:user_id => nil)
    assert_not degree
  end
  test "no level_id" do
    degree = Degree.first.update(:level_id => nil)
    assert_not degree
  end
  test "no completion year" do
    degree = Degree.first.update(:completion_year => nil)
    assert_not degree
  end
  test "wrong completion year" do
    degree = Degree.first.update(:completion_year => 2020)
    assert_not degree
  end
  test "no institution" do
    degree = Degree.first.update(:institution => nil)
    assert_not degree
  end
  test "all ok" do
    assert_difference "Degree.count" do
      Degree.create(:title => "Doctorat", :user_id => 1, :level_id => 20, :completion_year => 2000, :institution => "Saint-Luc")
    end
  end
end
