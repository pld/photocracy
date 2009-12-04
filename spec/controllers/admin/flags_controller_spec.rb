require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::FlagsController do
  fixtures :users

  before do
    login_as :smurf
  end

  def mock_flag(stubs={})
    @mock_flag ||= mock_model(Flag, stubs)
  end
  
  describe "responding to GET index" do

    it "should expose all flags as @flags" do
      Flag.should_receive(:find).with(:all).and_return([mock_flag])
      get :index
      assigns[:flags].should == [mock_flag]
    end

    describe "with mime type of xml" do
  
      it "should render all flags as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Flag.should_receive(:find).with(:all).and_return(flags = mock("Array of Flags"))
        flags.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested flag as @flag" do
      Flag.should_receive(:find).with("37").and_return(mock_flag)
      get :show, :id => "37"
      assigns[:flag].should equal(mock_flag)
    end
    
    describe "with mime type of xml" do

      it "should render the requested flag as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Flag.should_receive(:find).with("37").and_return(mock_flag)
        mock_flag.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested flag" do
      Flag.should_receive(:find).with("37").and_return(mock_flag)
      mock_flag.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the flags list" do
      Flag.stub!(:find).and_return(mock_flag(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(admin_flags_url)
    end

  end

end
