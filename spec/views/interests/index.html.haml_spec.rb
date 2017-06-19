require 'rails_helper'

RSpec.describe "interests/index", type: :view do
  before(:each) do
    assign(:interests, [
      Interest.create!(
        :student => nil,
        :topic => nil
      ),
      Interest.create!(
        :student => nil,
        :topic => nil
      )
    ])
  end

  xit "renders a list of interests" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
