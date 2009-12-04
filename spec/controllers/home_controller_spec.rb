require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HomeController do
  describe 'error' do
    it 'should assign error' do
      get :error
      assigns[:error].should_not == nil
    end
  end

  describe 'share' do
    fixtures :users

    before do
      login_as :quentin
      @mailing = mock_model(Mailing)
    end

    it 'should assign new post on get' do
      Mailing.should_receive(:new).with(no_args).and_return(@mailing)
      get :share
      assigns[:mailing].should == @mailing
    end

    describe 'post' do
      before do
        @params = { :mailing => { 'name' => 'jo', 'email' => 'jo@jo.com', 'message' => 'jo' } }
      end

      it 'should creating mailing' do
        Mailing.should_receive(:new).with(@params[:mailing].merge('user_id' => current_user.id)).and_return(@mailing)
        @mailing.should_receive(:save).and_return(false)
        post :share, @params
      end

      it 'should redirect on save' do
        Mailing.should_receive(:new).with(@params[:mailing].merge('user_id' => current_user.id)).and_return(@mailing)
        @mailing.should_receive(:save).and_return(true)
        post :share, @params
      end
    end
  end
end
