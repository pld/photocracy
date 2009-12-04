require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/prompts/show.html.haml" do
  include Admin::PromptsHelper
  
  before(:each) do
    assigns[:prompt] = @prompt = stub_model(Prompt
    )
  end

  it "should render attributes in <p>" do
    render "/admin/prompts/show.html.haml"
  end
end

