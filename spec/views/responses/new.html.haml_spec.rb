require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/responses/new.html.haml" do
  fixtures :prompts, :items_prompts, :items

  include ResponsesHelper

  before(:each) do
    assigns[:response] = stub_model(Response,
      :new_record? => true,
      :response_time => "1.5"
    )
    assigns[:question] = assigns[:question] = @question = stub_model(Question,
      :name => "value for name"
    )
    assigns[:prompt] = Prompt.first
  end

  it "should render new form" do
    render "/responses/new.html.haml"
  end
end


