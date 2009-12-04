require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationController do
  fixtures :users

  describe 'admin required' do
    it 'should redirect if not logged in' do
      @controller.should_receive(:redirect_back_or_default).with('/')
      @controller.current_user = false
      @controller.admin_required
    end

    describe 'when logged in' do
      it 'should redirect if not admin' do
        login_as :quentin
        @controller.should_receive(:redirect_back_or_default).with('/')
        @controller.admin_required
      end

      it 'should not redirect if admin' do
        login_as :smurf
        @controller.should_not_receive(:redirect_back_or_default)
      end
    end
  end

  describe 'flag obj' do
    before do
      @visit = Visit.create!(:ip_address => '1122')
      @flag = mock_model(Flag)
      @controller.stub!(:active_visit).and_return(@visit)
    end

    it 'should assign visit id' do
      params = {}
      params.should_receive(:[]=).with(:visit_id, @visit.id)
      @controller.flag_obj(params)
    end

    it 'should create flag' do
      Flag.should_receive(:create!).with({ :visit_id => @visit.id }).and_return(@flag)
      @flag.should_receive(:suspend).with(no_args)
      @controller.flag_obj({}).should == @flag
    end

    it 'should return false on invalid record' do
      @controller.flag_obj({}).should == false
    end
  end

  describe 'active question' do
    describe 'with nil question' do
      it 'should ask for random question' do
        Param.should_receive(:random_first_question?)
        @controller.active_question
      end
    end

    describe 'with question' do
      before do
        @question = 1112
        @request.session[:question] = @question
      end

      describe 'with true refresh question' do
        before do
          @controller.should_receive(:refresh_question?).and_return(true)
        end

        it 'should check prob' do
          Param.should_receive(:random_new_question_prob).with(no_args).and_return(0)
          @controller.active_question
        end
      end

      describe 'with false refresh question' do
        before do
          @controller.should_receive(:refresh_question?).and_return(false)
        end

        it 'should return session question' do
          @controller.active_question.should == @question
        end

        it 'should not set prompts' do
          @request.session.should_not_receive(:[]=).with(:prompts_shown)
          @controller.active_question
        end
      end
    end
  end

  describe 'active prompt assign' do
    before do
      @request.session[:prompts_shown] = 0
    end

    it 'should +1 prompts shown if new prompt' do
      @controller.active_prompt = 1
      @request.session[:prompts_shown].should == 1
    end

    it 'should not alter prompts if not new prompt' do
      @request.session[:prompt_id] = 1
      @controller.active_prompt = 1
      @request.session[:prompts_shown].should == 0
    end

    it 'should set prompt id' do
      @controller.active_prompt = 1
      @request.session[:prompt_id].should == 1
    end

    it 'should return passed id' do
      @controller.send(:active_prompt=, 1).should == 1
    end
  end
end
