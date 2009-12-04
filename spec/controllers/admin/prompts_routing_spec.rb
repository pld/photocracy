require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::PromptsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "admin/prompts", :action => "index").should == "/admin/prompts"
    end
  
    it "should map #new" do
      route_for(:controller => "admin/prompts", :action => "new").should == "/admin/prompts/new"
    end
  
    it "should map #show" do
      route_for(:controller => "admin/prompts", :action => "show", :id => 1).should == "/admin/prompts/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "admin/prompts", :action => "edit", :id => 1).should == "/admin/prompts/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "admin/prompts", :action => "update", :id => 1).should == "/admin/prompts/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "admin/prompts", :action => "destroy", :id => 1).should == "/admin/prompts/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/admin/prompts").should == {:controller => "admin/prompts", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/admin/prompts/new").should == {:controller => "admin/prompts", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/admin/prompts").should == {:controller => "admin/prompts", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/admin/prompts/1").should == {:controller => "admin/prompts", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/admin/prompts/1/edit").should == {:controller => "admin/prompts", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/admin/prompts/1").should == {:controller => "admin/prompts", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/admin/prompts/1").should == {:controller => "admin/prompts", :action => "destroy", :id => "1"}
    end
  end
end
