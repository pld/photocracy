require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/visits/index.html.haml" do
  include Admin::VisitsHelper
  
  before(:each) do
    assigns[:visits] = [
      stub_model(Visit,
        :ip_address => "value for ip_address",
        :ip_location => "value for ip_location"
      ),
      stub_model(Visit,
        :ip_address => "value for ip_address",
        :ip_location => "value for ip_location"
      )
    ]
  end

  it "should render list of visits" do
    render "/admin/visits/index.html.haml"
  end
end

