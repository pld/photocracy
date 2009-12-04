require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../attachment_spec_helper')
include Constants::Item

describe Item do
  include AttachmentSpecHelper
  before(:each) do
    @valid_attributes = {
      :agree => "1",
      :item_id_ext => "1",
      :name => "value for data"
    }
  end

  it "should create a new instance given valid attributes" do
    Item.create!(@valid_attributes)
  end

  describe 'valid items' do
    fixtures :questions

    before do
      @item = Item.create!(@valid_attributes)
    end

    it 'should get first question from questions' do
      @item.questions << Question.all
      @item.question.should == Question.first
    end

    describe 'rankings' do
      fixtures :items, :questions, :users
      
      before do
        Response.delete_all
        Question.delete_all('questions.id > 2')
        ItemsQuestion.delete_all
        @item = Item.first
        @item2 = Item.last
        @question = Question.find(1)
        @question2 = Question.find(2)
        @item.questions << @question << @question2
        @item2.questions << @question << @question2
        @user = User.first
        i = (Prompt.last) ? Prompt.last.prompt_id_ext : 0
        visit = Visit.create!(:ip_address => '12')
        [@question, @question2].each do |question|
          20.times do
            country = (i % 2).zero? ? 'US' : 'CN'
            prompt = Prompt.create!(:prompt_id_ext => i + 1, :question => question, :user => @user)
            prompt.items << @item << @item2
            response = Response.create!(:visit => visit, :prompt => prompt, :vote_id_ext => i + 1, :response_time => 15, :ip_country_code => country)
            response.items << ((i / 2 % 2).zero? ? @item : @item2) if (i % 2).zero?
            i += 1
            # item ratings get counted in controller since response is spawned so we
            # do the controllers work here
            prompt.items.each do |item|
              iq = item.items_questions.find_by_question_id(question.id)
              iq.increment!(:ratings)
              iq.increment!(:wins) if response.items.include?(item)
            end
          end
        end
        @join = "INNER JOIN visits ON (visits.id=responses.visit_id AND visits.ip_country_code='"
      end
      
      describe 'ratings' do
        it 'should count ratings for this item question default with skips' do
          @item.ratings(@question.id).should == 20
          @item2.ratings(@question.id).should == 20
        end
      
        it 'should count ratings without skips for this item question' do
          @item.ratings(@question.id, nil, false).should == 10
          @item2.ratings(@question.id, nil, false).should == 10
        end
      
        it 'should count ratings with skips for this item question' do
          @item.ratings(@question.id).should == 20
          @item2.ratings(@question.id).should == 20
        end
      
        describe 'with joins' do
          it 'should restrict with join' do
            @item.ratings(@question.id, @join + "US')").should == 10
            @item.ratings(@question.id, @join + "CN')").should == 10
            @item2.ratings(@question.id, @join + "US')").should == 10
            @item2.ratings(@question.id, @join + "CN')").should == 10
          end
      
          it 'should restrict with join and skips' do
            @item.ratings(@question.id, @join + "US')", false).should == 10
            @item.ratings(@question.id, @join + "CN')", false).should == 0
            @item2.ratings(@question.id, @join + "US')", false).should == 10
            @item2.ratings(@question.id, @join + "CN')", false).should == 0
          end
        end
      end
      
      describe 'wins' do
        it 'should count wins for question' do
          @item.wins(@question.id).should == 5
          @item2.wins(@question.id).should == 5
        end
      
        it 'should count wins for question with joins' do
          @item.wins(@question.id, @join + "US')").should == 5
          @item.wins(@question.id, @join + "CN')").should == 0
          @item2.wins(@question.id, @join + "US')").should == 5
          @item2.wins(@question.id, @join + "CN')").should == 0
        end
      end
      
      describe 'win_percent' do
        it 'should count win percent for question' do
          @item.win_percent(@question.id).should == 100 * (5 / 20.0)
          @item2.win_percent(@question.id).should == 100 * (5 / 20.0)
        end
      
        it 'should count win percent for question without skips' do
          @item.win_percent(@question.id, nil, false).should == 100 * (5 / 10.0)
          @item2.win_percent(@question.id, nil, false).should == 100 * (5 / 10.0)
        end
      
        it 'should count win percent with joins' do
          @item.win_percent(@question.id, @join + "US')").should == 100 * (5 / 10.0)
          @item.win_percent(@question.id, @join + "CN')").should == 100 * (0 / 10.0)
          @item2.win_percent(@question.id, @join + "US')").should == 100 * (5 / 10.0)
          @item2.win_percent(@question.id, @join + "CN')").should == 100 * (0 / 10.0)
        end
      end
      
      [nil, 1, 2].each do |question|
        describe "with question id #{question.inspect}" do
          describe 'percent wins' do
            before do
              @wins = question ? 5 : 10
              @with_skips = question ? 20.0 : 40.0
              @without_skips = question ? 10.0 : 20.0
              @with_joins = question ? 5.0 : 10.0
            end
      
            # it 'should get cached value' do
            #   @item.win_percent(question).should == 0.0
            #   @item2.win_percent(question).should == 0.0
            # end
      
            it 'should get percent wins' do
              @item.win_percent(question).should == 100 * (@wins / @with_skips)
              @item2.win_percent(question).should == 100 * (@wins / @with_skips)
            end
      
            # it 'should cache and get percent wins' do
            #   item = @item.win_percent(question, false)
            #   item2 = @item2.win_percent(question, false)
            #   @item.win_percent(question).should == item
            #   @item2.win_percent(question).should == item2
            # end
      
            it 'should get percent wins without skips' do
              @item.win_percent(question, nil, false).should == 100 * (@wins / @without_skips)
              @item2.win_percent(question, nil, false).should == 100 * (@wins / @without_skips)
            end
      
            it 'should restrict with joins' do
              # the skips ratings are equal to with skips given a country join
              @item.win_percent(question, @join + "US')").should == 100 * (@with_joins / @without_skips)
              @item.win_percent(question, @join + "CN')").should == 100 * (0 / @without_skips)
              @item2.win_percent(question, @join + "US')").should == 100 * (@with_joins / @without_skips)
              @item2.win_percent(question, @join + "CN')").should == 100 * (0 / @without_skips)
            end

            describe 'country' do
              it 'should restrict with joins' do
                # the skips ratings are equal to with skips given a country join
                @item.win_percent_for_country('US', question).should == 100 * (@with_joins / @without_skips)
                @item.win_percent_for_country('CN', question).should == 100 * (0 / @without_skips)
                @item2.win_percent_for_country('US', question).should == 100 * (@with_joins / @without_skips)
                @item2.win_percent_for_country('CN', question).should == 100 * (0 / @without_skips)
              end

              it 'should count skips if option passed' do
                @item.win_percent_for_country('US', question, false).should == 100 * (@with_joins / @without_skips)
              end
            end
          end

          describe 'position' do
            before do
              ItemsQuestion.update_all('position=5')
            end
      
            it 'should get correct position from join' do
              @item.position.should == 5
              @item2.position.should == 5
            end
          end
        end
      end
      
      describe 'changinge state' do
        before(:all) do
          Question.all.each do |question|
            question.update_attribute(:question_id_ext, ActiveRecord::Base.pairwise.question(question.name).first)
          end
      
          Item.all.each do |item|
            item.update_attribute(:item_id_ext, ActiveRecord::Base.pairwise.item(item.description, item.questions.map { |el| el.question_id_ext }).first)
          end
        end
      
        it 'should active item' do
          @item.suspend
          @item.activate
          @item.active.should == true
        end
      
        it 'should suspend item' do
          @item.activate
          @item.suspend
          @item.active.should == false
        end
      
        describe 'with prompts' do
          before do
            @item.prompts.delete_all
            count = Prompt.last.prompt_id_ext
            @item.prompts << Array.new(3).map { Prompt.create!(:question_id => 1, :prompt_id_ext => count += 1, :user_id => 0, :active => true) }
            @item.prompts << Array.new(3).map { Prompt.create!(:question_id => 1, :prompt_id_ext => count += 1, :user_id => 0, :active => false) }
          end
      
          it 'should suspend active prompts' do
            @item.prompts.count.should == 6
            @item.prompts.count(:conditions => { :active => true }).should == 3
            @item.suspend
            @item.prompts.count(:conditions => { :active => true }).should == 0
          end
        end
      end
    end

    describe 'refreshing stats' do
      fixtures :users
      
      before(:all) do
        Item.delete_all
        @questions = Array.new(3).map do
          Question.create!(:name => 'Quest', :question_id_ext => ActiveRecord::Base.pairwise.question('Quest').first)
        end
        @question = @questions.first
        count = 0
        @items = Array.new(10).map do
          item = Item.create!(:item_id_ext => ActiveRecord::Base.pairwise.item('Item', @questions.map { |q| q.question_id_ext }).first, :name => 'Item', :agree => '1')
          item.questions << @questions
          item.activate if ((count += 1) % 2).zero?
          item
        end
      end
      
      before do
      
      end
      
      describe 'refresh_rank?' do
        it 'should be true if there is a null position for any item' do
          Item.refresh_rank?(@question.id).should == true
        end
      
        it 'should be false otherwise' do
          set_item_positions(@question, 1)
          Item.refresh_rank?(@question.id).should == false
        end
      end
      
      describe 'refresh_rank' do
        it 'should return not update if refresh_rank? and response refresh are false' do
          set_item_positions(@question, 1)
          set_response_refresh(@question)
          Item.refresh_rank(@question).should == nil
          @items.each do |item|
            item.position(@question.id).should == 1.0
          end
        end
        
        it 'should update position for question' do
          Item.refresh_rank(@question)
          ActiveRecord::Base.pairwise.list(:item, @question.question_id_ext, RANK_ALGO_ID).each do |arr|
            item  = Item.find_by_item_id_ext(arr.first.to_i)
            item.position(@question.id).should == arr.last.to_i if item.active
          end
        end
        
        it 'should not update position for other questions' do
          Item.refresh_rank(@question)
          @items.each do |item|
            (@questions - [@question]).each do |question|
              item.position(question.id).should == 0.0
            end
          end
        end
        
        it 'should not update position for inactive items' do
          Item.refresh_rank(@question)
          @items.each do |item|
            if item.active
              item.position(@question.id).should == 1400.0
            else
              item.position(@question.id).should == 0.0
            end
          end
        end
        
        it 'should update last response' do
          Item.refresh_rank(@question)
          set_response_refresh(@question)
          Response.refresh_response?(LAST_RANK_RESPONSE, @question.id).should == false
        end
      end
      
      # describe 'refresh_percent' do
      #   it 'should update percent wins for only active items' do
      #     Item.refresh_percent(@question.id)
      #     @items.each do |item|
      #       if item.active
      #         item.win_percent(@question.id).should == item.win_percent(@question.id, false)
      #       else
      #         item.win_percent(@question.id).should == 0.0
      #       end
      #     end
      #   end
      #   
      #   it 'should update percent wins only for question' do
      #     Item.refresh_percent(@question.id)
      #     @items.each do |item|
      #       (@questions - [@question]).each do |question|
      #         item.win_percent(question.id).should == 0.0
      #       end
      #     end
      #   end
      #   
      #   it 'should update based on joins' do
      #     joins = "INNER JOIN visits ON (visits.id=responses.visit_id AND visits.ip_country_name='US')"
      #     Item.refresh_percent(@question.id, joins)
      #     @items.each do |item|
      #       if item.active
      #         item.win_percent(@question.id, true, true, joins).should == item.win_percent(@question.id, false, true, joins)
      #       else
      #         item.win_percent(@question.id).should == 0.0
      #       end
      #     end
      #   end
      #   
      #   it 'should not update if refresh response is false' do
      #     set_response_refresh(@question, LAST_PERCENT_RESPONSE)
      #     Item.refresh_percent(@question.id)
      #     @items.each do |item|
      #       item.win_percent(@question.id).should == 0.0
      #     end
      #   end
      #   
      #   it 'should update refresh response' do
      #     Item.refresh_percent(@question.id)
      #     set_response_refresh(@question, LAST_PERCENT_RESPONSE)
      #     Response.refresh_response?(LAST_PERCENT_RESPONSE, @question.id).should == false
      #   end
      # end
      
      # describe 'refresh_stats' do
      #   it 'should call other methods' do
      #     Item.refresh_stats(@question)
      #     @items.each do |item|
      #       if item.active
      #         item.position(@question.id).should == 1400.0
      #         # item.win_percent(@question.id).should == item.win_percent(@question.id, false)
      #       else
      #         item.position(@question.id).should == 0.0
      #         item.win_percent(@question.id).should == 0.0
      #       end
      #     end
      #   end
      # end
    end

    describe 'uploading' do
      before do
        Item.delete_all
        @item = Item.new(@valid_attributes)
        @attachment = Attachment.new(:uploaded_data => uploaded_data)
        @questions = Array.new(3).map do
          Question.create!(:name => 'Quest', :question_id_ext => ActiveRecord::Base.pairwise.question('Quest').first)
        end
        @question_ext_ids = @questions.map { |q| q.question_id_ext }
      end

      describe 'valid_objects' do
        it 'should validate objects' do
          Item.valid_objects(@item, @attachment, @question_ext_ids).should == true
        end

        it 'should require valid item' do
          @item.agree = nil
          Item.valid_objects(@item, @attachment, @question_ext_ids).should == false
        end

        it 'should require valid attachment' do
          @attachment.uploaded_data = nil
          @attachment.filename = nil
          Item.valid_objects(@item, @attachment, @question_ext_ids).should == false
        end

        it 'should require questions' do
          Item.valid_objects(@item, @attachment, []).should == false
        end

        it 'should requre valid item and attachment' do
          @attachment.uploaded_data = nil
          @attachment.filename = nil
          @item.agree = nil
          Item.valid_objects(@item, @attachment, @question_ext_ids).should == false
        end
      end

      describe 'new_remote' do
        before do
          @visit = Visit.create!(:ip_address => '12')
          Item.new_remote(@item, @attachment, @question_ext_ids, @visit.id)
          @r_item = Item.find_by_visit_id(@visit.id)
        end

        it 'should assign an external id' do
          (@r_item.item_id_ext.to_i > 0).should == true
        end

        it 'should assign a visit' do
          (@r_item.visit_id.to_i > 0).should == true
        end

        it 'should assign an attachment' do
          @r_item.attachment.should_not == nil
        end

        it 'should be saved' do
          @r_item.new_record?.should == nil
        end

        it 'should assign the questions' do
          sorted((@r_item.questions | @questions)).should == sorted(@questions)
        end
      end
    end

    describe 'parse params' do
      before do
        @params = {
          :item => @valid_attributes,
          :attachment => { :uploaded_data => uploaded_data },
          :question => { :a => 1, :b => 2, :c => 1 }
        }
      end

      it 'should create an item' do
        Item.parse_params(@params)[0].should be_instance_of(Item)
      end

      it 'should create an attachment' do
        Item.parse_params(@params)[1].should be_instance_of(Attachment)
      end

      it 'should uniqify questions' do
        Item.parse_params(@params)[2].should == @params[:question].values.uniq
      end
    end
  end

protected
  def set_item_positions(question, pos)
    question.items_questions.update_all("position=#{pos}")
  end

  def set_response_refresh(question, name = LAST_RANK_RESPONSE)
    Param.create(:name => "#{name}_#{question.id}", :value => 1)
  end

  def sorted(items)
    items.sort_by &:id
  end
end
