require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/flag_types/show.html.haml" do
  include Admin::FlagTypesHelper
  
  before(:each) do
    assigns[:flag_type] = @flag_type = stub_model(FlagType,
      :name => "value for name"
    )
  end

  it "should render attributes in <p>" do
    render "/admin/flag_types/show.html.haml"
    response.should have_text(/value\ for\ name/)
  end
end

