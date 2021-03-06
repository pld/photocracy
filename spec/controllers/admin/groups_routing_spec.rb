require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::GroupsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "admin/groups", :action => "index").should == "/admin/groups"
    end
  
    it "should map #new" do
      route_for(:controller => "admin/groups", :action => "new").should == "/admin/groups/new"
    end
  
    it "should map #show" do
      route_for(:controller => "admin/groups", :action => "show", :id => 1).should == "/admin/groups/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "admin/groups", :action => "edit", :id => 1).should == "/admin/groups/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "admin/groups", :action => "update", :id => 1).should == "/admin/groups/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "admin/groups", :action => "destroy", :id => 1).should == "/admin/groups/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/admin/groups").should == {:controller => "admin/groups", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/admin/groups/new").should == {:controller => "admin/groups", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/admin/groups").should == {:controller => "admin/groups", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/admin/groups/1").should == {:controller => "admin/groups", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/admin/groups/1/edit").should == {:controller => "admin/groups", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/admin/groups/1").should == {:controller => "admin/groups", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/admin/groups/1").should == {:controller => "admin/groups", :action => "destroy", :id => "1"}
    end
  end
end
