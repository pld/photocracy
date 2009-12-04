require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/items/index.html.haml" do
  include ItemsHelper
  
  before(:each) do
    assigns[:questions] = Question.all
    assigns[:question] = stub_model(Question,
      :name => "value for name"
    )
    assigns[:items] = [
      stub_model(Item,
        :data => "value for data",
        :created_at => Time.now
      ),
      stub_model(Item,
        :data => "value for data",
        :created_at => Time.now
      )
    ]
    assigns[:conditions] = { :page => 1 }
  end

  it "should render list of items" do
    render "/items/index.html.haml"
  end
end

