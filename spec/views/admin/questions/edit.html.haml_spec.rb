require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/questions/edit.html.haml" do
  include Admin::QuestionsHelper
  
  before(:each) do
    assigns[:question] = @question = stub_model(Question,
      :new_record? => false,
      :name => "value for name"
    )
  end

  it "should render edit form" do
    render "/admin/questions/edit.html.haml"
    
    response.should have_tag("form[action=#{admin_question_path(@question)}][method=post]") do
      with_tag('input#question_name[name=?]', "question[name]")
    end
  end
end


