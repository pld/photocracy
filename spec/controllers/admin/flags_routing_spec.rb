require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::FlagsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "admin/flags", :action => "index").should == "/admin/flags"
    end
  
    it "should map #new" do
      route_for(:controller => "admin/flags", :action => "new").should == "/admin/flags/new"
    end
  
    it "should map #show" do
      route_for(:controller => "admin/flags", :action => "show", :id => 1).should == "/admin/flags/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "admin/flags", :action => "edit", :id => 1).should == "/admin/flags/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "admin/flags", :action => "update", :id => 1).should == "/admin/flags/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "admin/flags", :action => "destroy", :id => 1).should == "/admin/flags/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/admin/flags").should == {:controller => "admin/flags", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/admin/flags/new").should == {:controller => "admin/flags", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/admin/flags").should == {:controller => "admin/flags", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/admin/flags/1").should == {:controller => "admin/flags", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/admin/flags/1/edit").should == {:controller => "admin/flags", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/admin/flags/1").should == {:controller => "admin/flags", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/admin/flags/1").should == {:controller => "admin/flags", :action => "destroy", :id => "1"}
    end
  end
end
