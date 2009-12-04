require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/groups/edit.html.haml" do
  include Admin::GroupsHelper
  
  before(:each) do
    assigns[:group] = @group = stub_model(Group,
      :new_record? => false,
      :name => "value for name",
      :code => "value for code"
    )
  end

  it "should render edit form" do
    render "/admin/groups/edit.html.haml"
    
    response.should have_tag("form[action=#{admin_group_path(@group)}][method=post]") do
      with_tag('input#group_name[name=?]', "group[name]")
      with_tag('input#group_code[name=?]', "group[code]")
    end
  end
end


