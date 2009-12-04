require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/flags/show.html.haml" do
  include Admin::FlagsHelper
  
  before(:each) do
    assigns[:flag] = @flag = stub_model(Flag,
      :content => "value for comment"
    )
  end

  it "should render attributes in <p>" do
    render "/admin/flags/show.html.haml"
  end
end

