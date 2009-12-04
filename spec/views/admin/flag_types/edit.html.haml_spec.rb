require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/flag_types/edit.html.haml" do
  include Admin::FlagTypesHelper
  
  before(:each) do
    assigns[:flag_type] = @flag_type = stub_model(FlagType,
      :new_record? => false,
      :name => "value for name"
    )
  end

  it "should render edit form" do
    render "/admin/flag_types/edit.html.haml"
    
    response.should have_tag("form[action=#{admin_flag_type_path(@flag_type)}][method=post]") do
      with_tag('input#flag_type_name[name=?]', "flag_type[name]")
    end
  end
end


