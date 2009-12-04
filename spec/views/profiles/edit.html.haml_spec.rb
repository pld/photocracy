require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/profiles/edit.html.haml" do
  include ProfilesHelper
  
  before(:each) do
    assigns[:profile] = @profile = stub_model(Profile,
      :new_record? => false,
      :langauge => "value for langauge"
    )
  end

  it "should render edit form" do
    render "/profiles/edit.html.haml"
  end
end