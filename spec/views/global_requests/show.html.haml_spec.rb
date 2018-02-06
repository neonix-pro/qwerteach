require 'rails_helper'

RSpec.describe "global_requests/show", type: :view do
  before(:each) do
    @global_request = assign(:global_request, GlobalRequest.create!(
      :user => nil,
      :topic => nil,
      :level => nil,
      :description => "MyText",
      :status => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/2/)
  end
end
