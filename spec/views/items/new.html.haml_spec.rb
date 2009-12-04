require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/items/new.html.haml" do
  include ItemsHelper
  
  before(:each) do
    assigns[:item] = stub_model(Item,
      :new_record? => true,
      :data => "value for data"
    )
    assigns[:items] = []
  end

  it "should render new form" do
    render "/items/new.html.haml"
  end
end


