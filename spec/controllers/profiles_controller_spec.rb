require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProfilesController do
  fixtures :users, :profiles

  def profile
    Profile.find_by_user_id(current_user.id)
  end

  def mock_profile(stubs={})
    @mock_profile ||= mock_model(Profile, stubs)
  end

  describe "before logging in" do
    before do
      request.env["HTTP_REFERER"] = "/index"
    end
    
    describe "responding to POST language" do
      it "should assign ignore invalid language" do
        post :language, :profile => { :locale => 'XXX' }
        session.should_not_receive(:[]=).with(:locale, 'XXX')
        session.should_not_receive(:[]=).with(:return_to, nil)
        response.should be_redirect
      end
      
      it "should change to language" do
        session.should_receive(:[]=).with(:visit, anything).at_least(:twice)
        session.should_receive(:[]=).with("flash", {}).once
        session.should_receive(:[]=).with(:return_to, nil).twice
        post :language, :profile => { :locale => "cn" }
        I18n.default_locale.should == "cn"
        response.should be_redirect
      end
    end
  end
  
  describe "after logging in" do
    before do
      login_as :quentin
    end

    describe "responding to POST language" do
      before do
        request.env["HTTP_REFERER"] = "/index"
      end
      
      it "should assign ignore invalid language" do
        post :language, :profile => { :language => 'XXX' }
        session.should_not_receive(:[]=).with(:language, 'XXX')
        session.should_not_receive(:[]=).with(:return_to, nil)
        response.should be_redirect
      end
      
      it "should assign valid language to current user's existing profile" do
        profile = Profile.find_by_user_id(1)
        post :language, :profile => { :locale => 'cn' }
        profile_after = Profile.find_by_user_id(1)
        profile.id.should == profile_after.id
        profile_after.locale.should == 'cn'
        response.should be_redirect
      end
      
      it "should assign valid language to new profile for current user" do
        profile = Profile.find_by_user_id(1)
        old_id = profile.id
        profile.destroy
        post :language, :profile => { :locale => 'cn' }
        profile = Profile.find_by_user_id(1)
        old_id.should_not == profile.id
        profile.locale.should == 'cn'
        response.should be_redirect
      end
    end

    describe "responding to GET show" do  
      it "should expose the current user's profile as @profile" do
        get :show, :id => "37"
        assigns[:profile].should == profile
      end
    end

    describe "responding to GET new with profile" do
      it "should expose a new profile as @profile" do
        get :new
        response.should be_redirect
      end
    end

    describe "responding to GET new without profile" do
      it "should expose a new profile as @profile" do
        profile.destroy
        Profile.should_receive(:new).and_return(mock_profile)
        get :new
        assigns[:profile].should equal(mock_profile)
      end
    end

    describe "responding to GET edit" do
      it "should expose the user's profile as @profile" do
        get :edit, :id => "37"
        assigns[:profile].should == profile
      end
    end

    describe "responding to POST create without profile" do
      before do
        profile.destroy
      end

      describe "with valid params" do
        it "should expose a newly created profile as @profile" do
          Profile.should_receive(:new).with({'user_id' => current_user.id, 'these' => 'params'}).and_return(mock_profile(:save => true))
          post :create, :profile => {:these => 'params'}
          assigns(:profile).should equal(mock_profile)
        end

        it "should redirect to the created profile" do
          Profile.stub!(:new).and_return(mock_profile(:save => true))
          post :create, :profile => {}
          response.should redirect_to(profile_url(mock_profile))
        end
      end

      # cannot pass invalid params
      # describe "with invalid params" do
      #   it "should expose a newly created but unsaved profile as @profile" do
      #     post :create, :profile => {}
      #     assigns(:profile).should equal(mock_profile)
      #   end
      # 
      #   it "should re-render the 'new' template" do
      #     post :create, :profile => {}
      #     response.should render_template('new')
      #   end
      # end
    end

    describe "responding to PUT update" do
      describe "with valid params" do
        it "should update the requested profile" do
          put :update, :id => "37", :profile => {:country => 'params'}
          assigns[:profile].country.should == 'params'
        end

        it "should expose the user profile as @profile" do
          put :update, :id => "1"
          assigns(:profile).should == profile
        end

        it "should redirect to the profile" do
          put :update, :id => "1"
          response.should redirect_to(profile_url(profile))
        end
      end

      # cannot pass invalid params
      describe "with invalid params" do
        it "should update the requested profile" do
          @controller.current_user.should_receive(:profile).at_least(1).times.and_return(mock_profile)
          # Profile.should_receive(:first).with(:conditions => {:user_id => 1}).and_return(mock_profile)
          mock_profile.should_receive(:locale)
          mock_profile.should_receive(:update_attributes).with({'country' => 'params'})
          put :update, :id => "37", :profile => {:country => 'params'}
        end
      
        it "should expose the profile as @profile" do
          @controller.current_user.should_receive(:profile).at_least(1).times.and_return(mock_profile)
          mock_profile.should_receive(:locale)
          mock_profile.should_receive(:update_attributes).and_return(false)
          # Profile.stub!(:find).and_return(mock_profile(:update_attributes => false))
          put :update, :id => "1"
          assigns(:profile).should equal(mock_profile)
        end
      
        it "should re-render the 'edit' template" do
          @controller.current_user.should_receive(:profile).at_least(1).times.and_return(mock_profile)
          mock_profile.should_receive(:locale)
          mock_profile.should_receive(:update_attributes).and_return(false)
          # Profile.stub!(:find).and_return(mock_profile(:update_attributes => false))
          put :update, :id => "1"
          response.should render_template('edit')
        end
      end
    end
  end
end
