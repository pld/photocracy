require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/questions/new.html.haml" do
  include Admin::QuestionsHelper
  
  before(:each) do
    assigns[:question] = stub_model(Question,
      :new_record? => true,
      :name => "value for name"
    )
  end

  it "should render new form" do
    render "/admin/questions/new.html.haml"
    
    response.should have_tag("form[action=?][method=post]", admin_questions_path) do
      with_tag("input#question_name[name=?]", "question[name]")
    end
  end
end


