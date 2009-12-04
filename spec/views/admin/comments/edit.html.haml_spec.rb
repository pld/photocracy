require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/comments/edit.html.haml" do
  include Admin::CommentsHelper
  
  before(:each) do
    assigns[:comment] = @comment = stub_model(Comment,
      :new_record? => false,
      :content => "value for content",
      :active => false
    )
  end

  it "should render edit form" do
    render "/admin/comments/edit.html.haml"
    
    response.should have_tag("form[action=#{admin_comment_path(@comment)}][method=post]") do
      with_tag('textarea#comment_content[name=?]', "comment[content]")
      with_tag('input#comment_active[name=?]', "comment[active]")
    end
  end
end


