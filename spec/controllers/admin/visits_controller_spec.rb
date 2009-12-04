require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::VisitsController do
  fixtures :users

  before do
    login_as :smurf
  end

  def mock_visit(stubs={})
    @mock_visit ||= mock_model(Visit, stubs)
  end
  
  describe "responding to GET index" do

    it "should expose all visits as @visits" do
      Visit.should_receive(:find).with(:all).and_return([mock_visit])
      get :index
      assigns[:visits].should == [mock_visit]
    end

    describe "with mime type of xml" do
  
      it "should render all visits as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Visit.should_receive(:find).with(:all).and_return(visits = mock("Array of Visits"))
        visits.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested visit as @visit" do
      Visit.should_receive(:find).with("37").and_return(mock_visit)
      get :show, :id => "37"
      assigns[:visit].should equal(mock_visit)
    end
    
    describe "with mime type of xml" do

      it "should render the requested visit as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Visit.should_receive(:find).with("37").and_return(mock_visit)
        mock_visit.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

  # describe "responding to GET new" do
  # 
  #   it "should expose a new visit as @visit" do
  #     Visit.should_receive(:new).and_return(mock_visit)
  #     get :new
  #     assigns[:visit].should equal(mock_visit)
  #   end
  # 
  # end
  # 
  # describe "responding to GET edit" do
  # 
  #   it "should expose the requested visit as @visit" do
  #     Visit.should_receive(:find).with("37").and_return(mock_visit)
  #     get :edit, :id => "37"
  #     assigns[:visit].should equal(mock_visit)
  #   end
  # 
  # end
  # 
  # describe "responding to POST create" do
  # 
  #   describe "with valid params" do
  #     
  #     it "should expose a newly created visit as @visit" do
  #       Visit.should_receive(:new).with({'these' => 'params'}).and_return(mock_visit(:save => true))
  #       post :create, :visit => {:these => 'params'}
  #       assigns(:visit).should equal(mock_visit)
  #     end
  # 
  #     it "should redirect to the created visit" do
  #       Visit.stub!(:new).and_return(mock_visit(:save => true))
  #       post :create, :visit => {}
  #       response.should redirect_to(visit_url(mock_visit))
  #     end
  #     
  #   end
  #   
  #   describe "with invalid params" do
  # 
  #     it "should expose a newly created but unsaved visit as @visit" do
  #       Visit.stub!(:new).with({'these' => 'params'}).and_return(mock_visit(:save => false))
  #       post :create, :visit => {:these => 'params'}
  #       assigns(:visit).should equal(mock_visit)
  #     end
  # 
  #     it "should re-render the 'new' template" do
  #       Visit.stub!(:new).and_return(mock_visit(:save => false))
  #       post :create, :visit => {}
  #       response.should render_template('new')
  #     end
  #     
  #   end
  #   
  # end
  # 
  # describe "responding to PUT udpate" do
  # 
  #   describe "with valid params" do
  # 
  #     it "should update the requested visit" do
  #       Visit.should_receive(:find).with("37").and_return(mock_visit)
  #       mock_visit.should_receive(:update_attributes).with({'these' => 'params'})
  #       put :update, :id => "37", :visit => {:these => 'params'}
  #     end
  # 
  #     it "should expose the requested visit as @visit" do
  #       Visit.stub!(:find).and_return(mock_visit(:update_attributes => true))
  #       put :update, :id => "1"
  #       assigns(:visit).should equal(mock_visit)
  #     end
  # 
  #     it "should redirect to the visit" do
  #       Visit.stub!(:find).and_return(mock_visit(:update_attributes => true))
  #       put :update, :id => "1"
  #       response.should redirect_to(visit_url(mock_visit))
  #     end
  # 
  #   end
  #   
  #   describe "with invalid params" do
  # 
  #     it "should update the requested visit" do
  #       Visit.should_receive(:find).with("37").and_return(mock_visit)
  #       mock_visit.should_receive(:update_attributes).with({'these' => 'params'})
  #       put :update, :id => "37", :visit => {:these => 'params'}
  #     end
  # 
  #     it "should expose the visit as @visit" do
  #       Visit.stub!(:find).and_return(mock_visit(:update_attributes => false))
  #       put :update, :id => "1"
  #       assigns(:visit).should equal(mock_visit)
  #     end
  # 
  #     it "should re-render the 'edit' template" do
  #       Visit.stub!(:find).and_return(mock_visit(:update_attributes => false))
  #       put :update, :id => "1"
  #       response.should render_template('edit')
  #     end
  # 
  #   end
  # 
  # end
  # 
  # describe "responding to DELETE destroy" do
  # 
  #   it "should destroy the requested visit" do
  #     Visit.should_receive(:find).with("37").and_return(mock_visit)
  #     mock_visit.should_receive(:destroy)
  #     delete :destroy, :id => "37"
  #   end
  # 
  #   it "should redirect to the visits list" do
  #     Visit.stub!(:find).and_return(mock_visit(:destroy => true))
  #     delete :destroy, :id => "1"
  #     response.should redirect_to(visits_url)
  #   end
  # 
  # end

end
