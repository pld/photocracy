require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::FlagTypesController do
  fixtures :users

  before do
    login_as :smurf
  end

  def mock_flag_type(stubs={})
    @mock_flag_type ||= mock_model(FlagType, stubs)
  end
  
  describe "responding to GET index" do

    it "should expose all flag_types as @flag_types" do
      FlagType.should_receive(:find).with(:all).and_return([mock_flag_type])
      get :index
      assigns[:flag_types].should == [mock_flag_type]
    end

    describe "with mime type of xml" do
  
      it "should render all flag_types as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        FlagType.should_receive(:find).with(:all).and_return(flag_types = mock("Array of FlagTypes"))
        flag_types.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested flag_type as @flag_type" do
      FlagType.should_receive(:find).with("37").and_return(mock_flag_type)
      get :show, :id => "37"
      assigns[:flag_type].should equal(mock_flag_type)
    end
    
    describe "with mime type of xml" do

      it "should render the requested flag_type as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        FlagType.should_receive(:find).with("37").and_return(mock_flag_type)
        mock_flag_type.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new flag_type as @flag_type" do
      FlagType.should_receive(:new).and_return(mock_flag_type)
      get :new
      assigns[:flag_type].should equal(mock_flag_type)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested flag_type as @flag_type" do
      FlagType.should_receive(:find).with("37").and_return(mock_flag_type)
      get :edit, :id => "37"
      assigns[:flag_type].should equal(mock_flag_type)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created flag_type as @flag_type" do
        FlagType.should_receive(:new).with({'these' => 'params'}).and_return(mock_flag_type(:save => true))
        post :create, :flag_type => {:these => 'params'}
        assigns(:flag_type).should equal(mock_flag_type)
      end

      it "should redirect to the created flag_type" do
        FlagType.stub!(:new).and_return(mock_flag_type(:save => true))
        post :create, :flag_type => {}
        response.should redirect_to(admin_flag_type_url(mock_flag_type))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved flag_type as @flag_type" do
        FlagType.stub!(:new).with({'these' => 'params'}).and_return(mock_flag_type(:save => false))
        post :create, :flag_type => {:these => 'params'}
        assigns(:flag_type).should equal(mock_flag_type)
      end

      it "should re-render the 'new' template" do
        FlagType.stub!(:new).and_return(mock_flag_type(:save => false))
        post :create, :flag_type => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested flag_type" do
        FlagType.should_receive(:find).with("37").and_return(mock_flag_type)
        mock_flag_type.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :flag_type => {:these => 'params'}
      end

      it "should expose the requested flag_type as @flag_type" do
        FlagType.stub!(:find).and_return(mock_flag_type(:update_attributes => true))
        put :update, :id => "1"
        assigns(:flag_type).should equal(mock_flag_type)
      end

      it "should redirect to the flag_type" do
        FlagType.stub!(:find).and_return(mock_flag_type(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(admin_flag_type_url(mock_flag_type))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested flag_type" do
        FlagType.should_receive(:find).with("37").and_return(mock_flag_type)
        mock_flag_type.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :flag_type => {:these => 'params'}
      end

      it "should expose the flag_type as @flag_type" do
        FlagType.stub!(:find).and_return(mock_flag_type(:update_attributes => false))
        put :update, :id => "1"
        assigns(:flag_type).should equal(mock_flag_type)
      end

      it "should re-render the 'edit' template" do
        FlagType.stub!(:find).and_return(mock_flag_type(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested flag_type" do
      FlagType.should_receive(:find).with("37").and_return(mock_flag_type)
      mock_flag_type.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the flag_types list" do
      FlagType.stub!(:find).and_return(mock_flag_type(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(admin_flag_types_url)
    end

  end

end
