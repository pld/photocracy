require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/responses/show.html.haml" do
  include Admin::ResponsesHelper
  
  before(:each) do
    assigns[:response] = @response = stub_model(Response
    )
  end

  it "should render attributes in <p>" do
    render "/admin/responses/show.html.haml"
  end
end

