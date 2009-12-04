require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/comments/show.html.haml" do
  include Admin::CommentsHelper
  
  before(:each) do
    assigns[:comment] = @comment = stub_model(Comment,
      :content => "value for content",
      :active => false
    )
  end

  it "should render attributes in <p>" do
    render "/admin/comments/show.html.haml"
    response.should have_text(/value\ for\ content/)
    response.should have_text(/als/)
  end
end

