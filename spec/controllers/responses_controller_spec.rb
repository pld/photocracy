require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include Constants::Responses

describe ResponsesController do

  def mock_response(stubs={})
    @mock_response ||= mock_model(Response, stubs)
  end

  describe "with out available prompts" do
    it "should redirect" do
      get :index
      response.should be_redirect
    end
  end
  
  describe "with available prompts" do
    fixtures :users, :questions, :items, :items_questions

    before(:all) do
      Question.all.each do |question|
        question.update_attribute(:question_id_ext, ActiveRecord::Base.pairwise.question(question.name).first)
      end
      Item.all(:limit => 6).each do |item|
        item.update_attribute(:item_id_ext, ActiveRecord::Base.pairwise.item(item.description, item.questions.map { |el| el.question_id_ext }).first)
        item.activate
      end
    end

    describe 'hack' do
      it 'should prep' do
      end
    end

    describe 'without logging in' do
      describe 'responding to GET new' do
        before do
          controller_setup
          get :new
        end
      
        it 'should expose a new prompt as @prompt' do
          assigns[:prompt].should_not == false
        end
      
        it 'should expose the active question' do
          assigns[:question].should_not == nil
        end
      
        it 'should set active prompt' do
          @controller.active_prompt.should == assigns[:prompt].id
        end

        it 'should assign last' do
          assigns[:last].id.should == @controller.last_prompt.id if @controller.last_prompt
        end

        it 'should assign last percent wins' do
          assigns[:last_percent_wins].empty?.should == false if assigns[:last]
        end
      end

      describe 'create' do
        before do
          create_setup
        end

        describe 'with first response time' do
          describe 'without item id' do
            before do
              post :create, @params
            end
            
            # this is all spawned
            # it 'should set response active prompt' do
            #   assigns[:response].prompt_id.should == @prompt.id
            # end
            #         
            # it 'should not assign response items' do
            #   assigns[:response].items.empty?.should == true
            # end
            #         
            # it 'should assign response active visit' do
            #   assigns[:response].visit.id.should == @controller.current_visit.id
            # end
            #         
            # it 'should assign response time' do
            #   assigns[:response].response_time.should == @params[:response_time] / MS_FACTOR
            # end
            #         
            # it 'should assign prompt id' do
            #   assigns[:response].prompt.should == @prompt
            # end
        
            # spawned so not guaranteed to be filled
            # it 'should get total votes' do
            #   assigns[:total_votes].should == (@votes + 1).to_s
            # end

            it 'should increment ratings' do
              assigns[:last].items.each_index do |idx|
                assigns[:last].items[idx].ratings(@question.id).should == @ratings[idx] + 1
                assigns[:last].items[idx].wins(@question.id).should == @wins[idx]
              end
            end
        
            it 'should get total uploads' do
              assigns[:total_uploads].should_not == nil
            end
        
            it 'should fetch prompt' do
              assigns[:prompt].should_not == false
            end

            describe 'last' do
              it 'should be assigned active prompt' do
                assigns[:last].id.should == @controller.last_prompt
              end

              it 'should deactivate' do
                assigns[:last].active.should == false
              end

              it 'should set visit id' do
                assigns[:last].visit_id.should == @controller.active_visit.id
              end
            end
            
          end
        
          describe 'with item id' do
            before do
              @item = @prompt.items.first
              @params.merge!({ :item_id => @item.id })
              post :create, @params
            end
        
            # it 'should assign winner' do
            #   assigns[:winner].should == @item
            # end

            # this is spawned
            # it 'should assign response winner' do
            #   assigns[:response].items.first.should == @item
            #   assigns[:response].items.length.should == 1
            # end

            it 'should fetch prompt' do
              assigns[:prompt].should_not == false
            end

            it 'should assign last' do
              assigns[:last].id.should == @controller.last_prompt
            end

            it 'should assign last percent wins' do
              assigns[:last_percent_wins].empty?.should == false
            end

            it 'should increment ratings' do
              assigns[:last].items.each_index do |idx|
                assigns[:last].items[idx].ratings(@question.id).should == @ratings[idx] + 1
                if assigns[:last].items[idx].id == @item.id
                  assigns[:last].items[idx].wins(@question.id).should == @wins[idx] + 1
                else
                  assigns[:last].items[idx].wins(@question.id).should == @wins[idx]
                end
              end
            end

          end
        end

        describe 'with multiple response times' do
          it 'should set be valid if lt min submit' do
            request.session[:response_time] = Array.new(TRACKED_RESPONSE_TIMES - 2, MIN_RESPONSE_TIMES)
            post :create, @params.merge(:response_time => MIN_RESPONSE_TIMES)
            assigns[:last].should_not == nil
          end

          it 'should be valid if gte min submit but over min total response time' do
            request.session[:response_time] = Array.new(TRACKED_RESPONSE_TIMES - 1, 0)
            post :create, @params.merge(:response_time => (MIN_RESPONSE_TIMES + 1) * MS_FACTOR)
            assigns[:last].should_not == nil
          end

          it 'should be invalid otherwise' do
            request.session[:response_time] = Array.new(TRACKED_RESPONSE_TIMES - 1, 0)
            post :create, @params.merge(:response_time => MIN_RESPONSE_TIMES * MS_FACTOR)
            assigns[:last].should == nil
          end
        end
      end

      describe 'flag' do
        before do
          @item = Item.first
          @params = { :flag => { :item_id => @item.id, :flag_type_id => "1" } }
        end

        it 'should fail with invalid params' do
          post :flag, :flag => {}
        end

        it 'should create flag for item' do
          post :flag, @params
          Flag.find_by_item_id(@item.id).should_not == nil
        end

        it 'should fetch prompt' do
          post :flag, @params
          assigns[:prompt].should_not == false
        end
      end
    end

    describe 'with logging in' do
      before do
        login_as :quentin
      end

      describe 'responding to GET new' do
        before do
          get :new
        end

        it 'should get prompt for user' do
          assigns[:prompt].user_id.should == current_user.id
        end
      end

      describe 'create' do
        before do
          create_setup
        end

        # spawned
        # it 'should assign pass user ext id' do
        #   Response.should_receive(:create_for_prompt).with(@prompt, 0, current_user.voter_id_ext, { :visit_id => @visit.id, :response_time => 15000, :prompt_id => @prompt.id })
        #   post :create, @params
        # end
      end
    end
  end

protected
  def controller_setup
    @controller.active_visit = Visit.create!(:ip_address => '112')
  end

  def create_setup
    controller_setup
    @question = @controller.active_question
    @visit = @controller.current_visit
    @prompts_shown = @controller.prompts_shown
    @prompt, @fetch = Prompt.fetch(0, 0, @question, @visit, @prompts_shown)
    @controller.active_prompt = @prompt.id
    @params = { :response_time => 150000 }
    @votes = Response.count
    @ratings = @prompt.items.map { |i| i.ratings(@question.id) }
    @wins = @prompt.items.map { |i| i.wins(@question.id) }
  end
end