require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/groups/index.html.haml" do
  include Admin::GroupsHelper
  
  before(:each) do
    assigns[:groups] = [
      stub_model(Group,
        :name => "value for name",
        :code => "value for code"
      ),
      stub_model(Group,
        :name => "value for name",
        :code => "value for code"
      )
    ]
  end

  it "should render list of admin/groups" do
    render "/admin/groups/index.html.haml"
    response.should have_tag("tr>td", "value for name", 2)
    response.should have_tag("tr>td", "value for code", 2)
  end
end

