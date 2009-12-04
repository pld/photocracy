require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/questions/index.html.haml" do
  include Admin::QuestionsHelper
  
  before(:each) do
    assigns[:questions] = []
  end

  it "should render list of questions" do
    render "/admin/questions/index.html.haml"
  end
end

