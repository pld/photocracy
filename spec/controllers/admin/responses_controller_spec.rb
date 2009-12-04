require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::ResponsesController do
  fixtures :users, :responses

  before do
    login_as :smurf
  end

  def mock_response(stubs={})
    @mock_response ||= mock_model(Response, stubs)
  end
  
  describe "responding to GET index" do

    it "should expose all responses as @responses" do
      Response.should_receive(:find).with(:all).and_return([mock_response])
      get :index
      assigns[:responses].should == [mock_response]
    end

    describe "with mime type of xml" do
      it "should render all responses as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Response.should_receive(:find).with(:all).and_return(responses = mock("Array of Responses"))
        responses.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    end

  end

  describe "responding to GET show" do

    it "should expose the requested response as @response" do
      Response.should_receive(:find).with("37").and_return(mock_response)
      get :show, :id => "37"
      assigns[:response].should equal(mock_response)
    end
    
    describe "with mime type of xml" do

      it "should render the requested response as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Response.should_receive(:find).with("37").and_return(mock_response)
        mock_response.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end
end
