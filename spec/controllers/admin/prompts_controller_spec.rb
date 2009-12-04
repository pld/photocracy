require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::PromptsController do
  fixtures :users

  before do
    login_as :smurf
  end

  def mock_prompt(stubs={})
    @mock_prompt ||= mock_model(Prompt, stubs)
  end
  
  describe "responding to GET index" do

    it "should expose all prompts as @prompts" do
      Prompt.should_receive(:find).with(:all).and_return([mock_prompt])
      get :index
      assigns[:prompts].should == [mock_prompt]
    end

    describe "with mime type of xml" do
  
      it "should render all prompts as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Prompt.should_receive(:find).with(:all).and_return(prompts = mock("Array of Prompts"))
        prompts.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested prompt as @prompt" do
      Prompt.should_receive(:find).with("37").and_return(mock_prompt)
      get :show, :id => "37"
      assigns[:prompt].should equal(mock_prompt)
    end
    
    describe "with mime type of xml" do

      it "should render the requested prompt as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Prompt.should_receive(:find).with("37").and_return(mock_prompt)
        mock_prompt.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

end
