require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/flags/index.html.haml" do
  include Admin::FlagsHelper
  
  before(:each) do
    assigns[:flags] = [
      stub_model(Flag,
        :content => "value for comment"
      ),
      stub_model(Flag,
        :content => "value for comment"
      )
    ]
  end

  it "should render list of flags" do
    render "/admin/flags/index.html.haml"
  end
end

