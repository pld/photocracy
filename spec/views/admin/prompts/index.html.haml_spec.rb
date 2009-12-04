require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/prompts/index.html.haml" do
  include Admin::PromptsHelper
  
  before(:each) do
    assigns[:prompts] = [
      stub_model(Prompt),
      stub_model(Prompt)
    ]
  end

  it "should render list of prompts" do
    render "/admin/prompts/index.html.haml"
  end
end

