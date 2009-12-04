require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ItemsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "items", :action => "index").should == "/items"
    end
  
    it "should map #new" do
      route_for(:controller => "items", :action => "new").should == "/items/new"
    end
  
    it "should map #show" do
      route_for(:controller => "items", :action => "show", :id => 1).should == "/items/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "items", :action => "edit", :id => 1).should == "/items/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "items", :action => "update", :id => 1).should == "/items/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "items", :action => "destroy", :id => 1).should == "/items/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/items").should == {:controller => "items", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/items/new").should == {:controller => "items", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/items").should == {:controller => "items", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/items/1").should == {:controller => "items", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/items/1/edit").should == {:controller => "items", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/items/1").should == {:controller => "items", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/items/1").should == {:controller => "items", :action => "destroy", :id => "1"}
    end
  end
end
