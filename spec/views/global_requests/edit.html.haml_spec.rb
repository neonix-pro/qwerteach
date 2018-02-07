require 'rails_helper'

RSpec.describe "global_requests/edit", type: :view do
  before(:each) do
    @global_request = assign(:global_request, GlobalRequest.create!(
      :user => nil,
      :topic => nil,
      :level => nil,
      :description => "MyText",
      :status => 1
    ))
  end

  it "renders the edit global_request form" do
    render

    assert_select "form[action=?][method=?]", global_request_path(@global_request), "post" do

      assert_select "input#global_request_user_id[name=?]", "global_request[user_id]"

      assert_select "input#global_request_topic_id[name=?]", "global_request[topic_id]"

      assert_select "input#global_request_level_id[name=?]", "global_request[level_id]"

      assert_select "textarea#global_request_description[name=?]", "global_request[description]"

      assert_select "input#global_request_status[name=?]", "global_request[status]"
    end
  end
end
