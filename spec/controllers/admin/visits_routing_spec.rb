require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::VisitsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "admin/visits", :action => "index").should == "/admin/visits"
    end
  
    it "should map #new" do
      route_for(:controller => "admin/visits", :action => "new").should == "/admin/visits/new"
    end
  
    it "should map #show" do
      route_for(:controller => "admin/visits", :action => "show", :id => 1).should == "/admin/visits/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "admin/visits", :action => "edit", :id => 1).should == "/admin/visits/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "admin/visits", :action => "update", :id => 1).should == "/admin/visits/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "admin/visits", :action => "destroy", :id => 1).should == "/admin/visits/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/admin/visits").should == {:controller => "admin/visits", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/admin/visits/new").should == {:controller => "admin/visits", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/admin/visits").should == {:controller => "admin/visits", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/admin/visits/1").should == {:controller => "admin/visits", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/admin/visits/1/edit").should == {:controller => "admin/visits", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/admin/visits/1").should == {:controller => "admin/visits", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/admin/visits/1").should == {:controller => "admin/visits", :action => "destroy", :id => "1"}
    end
  end
end
