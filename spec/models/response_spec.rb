require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include Constants::Responses

describe Response do
  before(:each) do
    Response.delete_all
    @valid_attributes = {
      :prompt_id => '1',
      :visit_id => "1",
      :vote_id_ext => "1",
      :response_time => "15"
    }
  end

  it "should create a new instance given valid attributes" do
    Response.create!(@valid_attributes)
  end

  describe 'refresh response?' do
    before do
      Prompt.delete_all
      @name = 'name'
      @qid = 1
      @param = Param.create(:name => "#{@name}_#{@qid}", :value => 0)
    end

    it 'should be true if param is not found' do
      Param.find_by_name('invalid').should == nil
      Response.refresh_response?('invalid', 1).should == true
    end

    it 'should be false if count is less than const' do
      Response.refresh_response?(@name, @qid).should == false
    end

    it 'should be false if count is equal to const' do
      count = 0
      RESPONSES_UNTIL_NEW_RANK.times do
        prompt = Prompt.create(:question_id => @qid, :prompt_id_ext => count += 1, :user_id => 0)
        Response.create(:prompt_id => prompt.id, :visit_id => 1, :vote_id_ext => count, :response_time => 10)
      end
      Response.refresh_response?(@name, @qid).should == false
    end

    it 'should be true if count is greater than const' do
      count = 0
      (RESPONSES_UNTIL_NEW_RANK + 1).times do
        prompt = Prompt.create(:question_id => @qid, :prompt_id_ext => count += 1, :user_id => 0)
        Response.create(:prompt_id => prompt.id, :visit_id => 1, :vote_id_ext => count, :response_time => 10)
      end
      Response.refresh_response?(@name, @qid).should == true
    end
  end

  describe 'update last response' do
    before do
      @name = 'name'
      @qid = 1
    end

    it 'should do nothing if no responses' do
      Response.update_last_response(@name, @qid)
      Param.find_by_name("#{@name}_#{@qid}").should == nil
    end

    describe 'with last response' do
      before do
        Response.create!(@valid_attributes)
      end

      it 'should create param if no param' do
        Response.update_last_response(@name, @qid)
        Param.find_by_name("#{@name}_#{@qid}").value.should == Response.last.id.to_s
      end
        
      it 'should update param if param' do
        Response.update_last_response(@name, @qid)
        Response.create!(@valid_attributes.merge(:prompt_id => 2, :vote_id_ext => 2))
        Response.update_last_response(@name, @qid)
        Param.find_by_name("#{@name}_#{@qid}").value.should == Response.last.id.to_s
      end
    end
  end

  describe 'create for prompt' do
    fixtures :items, :items_questions, :questions

    before(:all) do
      Question.all.each do |question|
        question.update_attribute(:question_id_ext, ActiveRecord::Base.pairwise.question(question.name).first)
      end

      Item.all.each do |item|
        item.update_attribute(:item_id_ext, ActiveRecord::Base.pairwise.item(item.description, item.questions.map { |el| el.question_id_ext }).first)
        item.activate
      end
    end
    
    before do
      @question = Question.first
      @visit = Visit.create(:ip_address => "127.0.0.1")
      @prompt, @fetch = Prompt.fetch(0, 0, @question, @visit, 0)
    end

    describe 'hack' do
      it 'should prep' do
      end
    end

    describe 'with invalid params' do
      it 'should return nil and not change' do
        @prompt.update_attribute(:prompt_id_ext, @prompt.prompt_id_ext + 1)
        Response.create_for_prompt(@prompt, @prompt.items.first.item_id_ext, 0, {}).should == nil
      end
    end

    describe 'with valid params' do
      before do
        @options = { :visit_id => 5, :response_time => 10, :prompt_id => @prompt.id }
        @response = Response.create_for_prompt(@prompt, @prompt.items.first.item_id_ext, 0, @options)
      end

      it 'should return a saved response' do
        @response.new_record?.should == false
      end
      
      it 'should set the vote id ext' do
        @response.vote_id_ext.should_not == nil
      end
    end
  end
end
