require 'rails_helper'

RSpec.describe "interests/show", type: :view do
  before(:each) do
    @interest = assign(:interest, Interest.create!(
      :student => nil,
      :topic => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
