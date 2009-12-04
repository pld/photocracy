require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::QuestionsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "admin/questions", :action => "index").should == "/admin/questions"
    end
  
    it "should map #new" do
      route_for(:controller => "admin/questions", :action => "new").should == "/admin/questions/new"
    end
  
    it "should map #show" do
      route_for(:controller => "admin/questions", :action => "show", :id => 1).should == "/admin/questions/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "admin/questions", :action => "edit", :id => 1).should == "/admin/questions/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "admin/questions", :action => "update", :id => 1).should == "/admin/questions/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "admin/questions", :action => "destroy", :id => 1).should == "/admin/questions/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/admin/questions").should == {:controller => "admin/questions", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/admin/questions/new").should == {:controller => "admin/questions", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/admin/questions").should == {:controller => "admin/questions", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/admin/questions/1").should == {:controller => "admin/questions", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/admin/questions/1/edit").should == {:controller => "admin/questions", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/admin/questions/1").should == {:controller => "admin/questions", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/admin/questions/1").should == {:controller => "admin/questions", :action => "destroy", :id => "1"}
    end
  end
end
