require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/comments/index.html.haml" do
  fixtures :comments, :items, :visits, :users

  include Admin::CommentsHelper
  
  before(:each) do
    assigns[:comments] = Comment.page_find
  end

  it "should render list of comments" do
    render "/admin/comments/index.html.haml"
  end
end

