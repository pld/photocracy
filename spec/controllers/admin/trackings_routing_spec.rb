require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::TrackingsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "admin/trackings", :action => "index").should == "/admin/trackings"
    end
  
    it "should map #new" do
      route_for(:controller => "admin/trackings", :action => "new").should == "/admin/trackings/new"
    end
  
    it "should map #show" do
      route_for(:controller => "admin/trackings", :action => "show", :id => 1).should == "/admin/trackings/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "admin/trackings", :action => "edit", :id => 1).should == "/admin/trackings/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "admin/trackings", :action => "update", :id => 1).should == "/admin/trackings/1"
    end
  
    it "should map #destroy" do
      route_for(:controller => "admin/trackings", :action => "destroy", :id => 1).should == "/admin/trackings/1"
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/admin/trackings").should == {:controller => "admin/trackings", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/admin/trackings/new").should == {:controller => "admin/trackings", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/admin/trackings").should == {:controller => "admin/trackings", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/admin/trackings/1").should == {:controller => "admin/trackings", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/admin/trackings/1/edit").should == {:controller => "admin/trackings", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/admin/trackings/1").should == {:controller => "admin/trackings", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/admin/trackings/1").should == {:controller => "admin/trackings", :action => "destroy", :id => "1"}
    end
  end
end
