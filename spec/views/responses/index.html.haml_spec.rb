require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/responses/index.html.haml" do
  include ResponsesHelper
  
  before(:each) do
    assigns[:limit] = '10'
    assigns[:question] = assigns[:question] = @question = stub_model(Question,
      :name => "value for name"
    )
    assigns[:items] = Item.all.map { |i| [[Item.first], [i]] }
  end

  it "should render list of responses" do
    render "/responses/index.html.haml"
  end
end

