require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::TrackingsController do
  fixtures :users, :trackings

  before do
    login_as :smurf
  end

  def mock_tracking(stubs={})
    @mock_tracking ||= mock_model(Tracking, stubs)
  end
  
  describe "responding to GET index" do

    it "should expose all trackings as @trackings" do
      Tracking.should_receive(:find).with(:all, {:offset=>0, :order=>"trackings.created_at desc", :limit=>25}).and_return([mock_tracking])
      get :index
      assigns[:trackings].should == [mock_tracking]
    end

    describe "with mime type of xml" do
      it "should render all trackings as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        trackings = Tracking.all
        Tracking.should_receive(:page_find).and_return(trackings)
        trackings.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    end

  end

  describe "responding to GET show" do

    it "should expose the requested tracking as @tracking" do
      Tracking.should_receive(:find).with("37").and_return(mock_tracking)
      get :show, :id => "37"
      assigns[:tracking].should equal(mock_tracking)
    end
    
    describe "with mime type of xml" do

      it "should render the requested tracking as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Tracking.should_receive(:find).with("37").and_return(mock_tracking)
        mock_tracking.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end
end
