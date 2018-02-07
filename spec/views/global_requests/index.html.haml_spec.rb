require 'rails_helper'

RSpec.describe "global_requests/index", type: :view do
  before(:each) do
    assign(:global_requests, [
      GlobalRequest.create!(
        :user => nil,
        :topic => nil,
        :level => nil,
        :description => "MyText",
        :status => 2
      ),
      GlobalRequest.create!(
        :user => nil,
        :topic => nil,
        :level => nil,
        :description => "MyText",
        :status => 2
      )
    ])
  end

  it "renders a list of global_requests" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
