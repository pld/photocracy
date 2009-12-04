require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::CommentsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "admin/comments", :action => "index").should == "/admin/comments"
    end
  
    it "should map #new" do
      route_for(:controller => "admin/comments", :action => "new").should == "/admin/comments/new"
    end
  
    it "should map #show" do
      route_for(:controller => "admin/comments", :action => "show", :id => 1).should == "/admin/comments/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "admin/comments", :action => "edit", :id => 1).should == "/admin/comments/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "admin/comments", :action => "update", :id => 1).should == "/admin/comments/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "admin/comments", :action => "destroy", :id => 1).should == "/admin/comments/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/admin/comments").should == {:controller => "admin/comments", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/admin/comments/new").should == {:controller => "admin/comments", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/admin/comments").should == {:controller => "admin/comments", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/admin/comments/1").should == {:controller => "admin/comments", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/admin/comments/1/edit").should == {:controller => "admin/comments", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/admin/comments/1").should == {:controller => "admin/comments", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/admin/comments/1").should == {:controller => "admin/comments", :action => "destroy", :id => "1"}
    end
  end
end
