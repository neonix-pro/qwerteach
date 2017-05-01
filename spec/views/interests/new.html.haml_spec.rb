require 'rails_helper'

RSpec.describe "interests/new", type: :view do
  before(:each) do
    assign(:interest, Interest.new(
      :student => nil,
      :topic => nil
    ))
  end

  it "renders new interest form" do
    render

    assert_select "form[action=?][method=?]", interests_path, "post" do

      assert_select "input#interest_student_id[name=?]", "interest[student_id]"

      assert_select "input#interest_topic_id[name=?]", "interest[topic_id]"
    end
  end
end
