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
      assert_select 'input[name=?]', 'interest[student]'
      assert_select 'input[name=?]', 'interest[topic]'
    end
  end
end
