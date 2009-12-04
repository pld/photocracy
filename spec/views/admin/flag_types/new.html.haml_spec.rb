require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/flag_types/new.html.haml" do
  include Admin::FlagTypesHelper
  
  before(:each) do
    assigns[:flag_type] = stub_model(FlagType,
      :new_record? => true,
      :name => "value for name"
    )
  end

  it "should render new form" do
    render "/admin/flag_types/new.html.haml"
    
    response.should have_tag("form[action=?][method=post]", admin_flag_types_path) do
      with_tag("input#flag_type_name[name=?]", "flag_type[name]")
    end
  end
end


