require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/responses/index.html.haml" do
  include Admin::ResponsesHelper
  
  before(:each) do
    assigns[:responses] = [
      stub_model(Response),
      stub_model(Response)
    ]
  end

  it "should render list of responses" do
    render "/admin/responses/index.html.haml"
  end
end

