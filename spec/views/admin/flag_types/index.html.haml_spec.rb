require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/flag_types/index.html.haml" do
  include Admin::FlagTypesHelper
  
  before(:each) do
    assigns[:flag_types] = [
      stub_model(FlagType,
        :name => "value for name"
      ),
      stub_model(FlagType,
        :name => "value for name"
      )
    ]
  end

  it "should render list of flag_types" do
    render "/admin/flag_types/index.html.haml"
    response.should have_tag("tr>td", "value for name", 2)
  end
end

