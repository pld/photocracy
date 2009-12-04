require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/questions/show.html.haml" do
  fixtures :questions

  include Admin::QuestionsHelper
  
  before(:each) do
    assigns[:question] = @question = Question.first
  end

  it "should render attributes in <p>" do
    render "/admin/questions/show.html.haml"
  end
end

