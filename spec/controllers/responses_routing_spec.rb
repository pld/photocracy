require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ResponsesController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "responses", :action => "index").should == "/responses"
    end
  
    it "should map #new" do
      route_for(:controller => "responses", :action => "new").should == "/responses/new"
    end
  
    it "should map #show" do
      route_for(:controller => "responses", :action => "show", :id => 1).should == "/responses/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "responses", :action => "edit", :id => 1).should == "/responses/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "responses", :action => "update", :id => 1).should == "/responses/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "responses", :action => "destroy", :id => 1).should == "/responses/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/responses").should == {:controller => "responses", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/responses/new").should == {:controller => "responses", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/responses").should == {:controller => "responses", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/responses/1").should == {:controller => "responses", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/responses/1/edit").should == {:controller => "responses", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/responses/1").should == {:controller => "responses", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/responses/1").should == {:controller => "responses", :action => "destroy", :id => "1"}
    end
  end
end
