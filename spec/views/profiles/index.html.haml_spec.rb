require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/profiles/index.html.haml" do
  include ProfilesHelper
  
  before(:each) do
    assigns[:profiles] = [
      stub_model(Profile,
        :user_id => User.first,
        :langauge => "value for langauge"
      ),
      stub_model(Profile,
        :user_id => User.first,
        :langauge => "value for langauge"
      )
    ]
  end

  it "should render list of profiles" do
    render "/profiles/index.html.haml"
  end
end

