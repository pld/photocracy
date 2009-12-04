require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/visits/show.html.haml" do
  include Admin::VisitsHelper
  
  before(:each) do
    assigns[:visit] = @visit = stub_model(Visit,
      :ip_address => "value for ip_address",
      :ip_location => "value for ip_location"
    )
  end

  it "should render attributes in <p>" do
    render "/admin/visits/show.html.haml"
  end
end

