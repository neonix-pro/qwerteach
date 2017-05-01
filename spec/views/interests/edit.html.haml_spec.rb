require 'rails_helper'

RSpec.describe "interests/edit", type: :view do
  before(:each) do
    @interest = assign(:interest, Interest.create!(
      :student => nil,
      :topic => nil
    ))
  end

  it "renders the edit interest form" do
    render

    assert_select "form[action=?][method=?]", interest_path(@interest), "post" do

      assert_select "input#interest_student_id[name=?]", "interest[student_id]"

      assert_select "input#interest_topic_id[name=?]", "interest[topic_id]"
    end
  end
end
