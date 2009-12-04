require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/groups/new.html.haml" do
  include Admin::GroupsHelper
  
  before(:each) do
    assigns[:group] = stub_model(Group,
      :new_record? => true,
      :name => "value for name",
      :code => "value for code"
    )
  end

  it "should render new form" do
    render "/admin/groups/new.html.haml"
  end
end


