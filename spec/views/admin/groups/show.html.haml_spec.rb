require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/groups/show.html.haml" do
  include Admin::GroupsHelper
  
  before(:each) do
    assigns[:group] = @group = stub_model(Group,
      :name => "value for name",
      :code => "value for code"
    )
  end

  it "should render attributes in <p>" do
    render "/admin/groups/show.html.haml"
    response.should have_text(/value\ for\ name/)
    response.should have_text(/value\ for\ code/)
  end
end

