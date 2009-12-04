require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/items/show.html.haml" do
  include ItemsHelper
  
  before(:each) do
    assigns[:item] = @item = stub_model(Item,
      :data => "value for data"
    )
  end

  it "should render attributes in <p>" do
    render "/items/show.html.haml"
  end
end

