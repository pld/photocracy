require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include Constants::Prompts

describe Prompt do
  before(:each) do
    @valid_attributes = {
      :question_id => "1",
      :prompt_id_ext => "1",
      :user_id => '0'
    }
  end

  it "should create a new instance given valid attributes" do
    Prompt.create!(@valid_attributes)
  end

  describe "fetch" do
    fixtures :users, :questions, :items, :items_questions

    before(:all) do
      Prompt.delete_all
      Question.all.each do |question|
        question.update_attribute(:question_id_ext, ActiveRecord::Base.pairwise.question(question.name).first)
      end
      Item.all.each do |item|
        item.update_attribute(:item_id_ext, ActiveRecord::Base.pairwise.item(item.description, item.questions.map { |el| el.question_id_ext }).first)
        item.activate
      end
      @user = User.first
      @question = Question.first
      @visit = Visit.create(:user_id => @user.id, :ip_address => "127.0.0.1")
    end

    describe 'hack' do
      it 'should prep' do
      end
    end

    describe "primed prompt" do
      before do
        @items = Item.all(:order => 'items_questions.wins/items_questions.ratings desc', :limit => DEFAULT_PRIME_TOP, :conditions => { 'items.active' => true, 'items_questions.question_id' => @question.id }, :group => 'items.id', :include => :items_questions, :select => "items.id, items.item_id_ext")
      end

      describe "for user" do
        before do
          @prompt, @fetch = Prompt.fetch(@user.id, @user.voter_id_ext, @question, @visit, 0)
        end

        it "should set the visit" do; @prompt.visit_id.should == @visit.id end
        it "should set the question" do; @prompt.question_id.should == @question.id end
        it "should set the ext id" do; @prompt.prompt_id_ext.should_not == nil end
        it "should limit items" do; sorted(@prompt.items | @items).should == sorted(@items) end
      end

      describe "without user" do
        before do
          @prompt, @fetch = Prompt.fetch(0, 0, @question, @visit, PRIME_FOR.to_i)
        end
        
        it "should assign an anonymous id" do; @prompt.user_id.should == ANONYMOUS_USER_ID end
        it "should limit items" do; sorted(@prompt.items | @items).should == sorted(@items) end
      end
    end

    describe "not primed prompt" do
      describe "for user" do
        before do
          @prompt, @fetch = Prompt.fetch(@user.id, @user.voter_id_ext, @question, @visit, PRIME_FOR.to_i)
        end

        it "should not limit items" do
          items = Item.all(:conditions => { 'items.active' => true, 'items_questions.question_id' => @question.id }, :group => 'items.id', :include => :items_questions, :select => "items.id, items.item_id_ext")
          sorted(@prompt.items | items).should == sorted(items)
        end
      end

      describe "without user" do
        before do
          @prompt, @fetch = Prompt.fetch(0, 0, @question, @visit, PRIME_FOR.to_i)
        end

        it "should assign an anonymous id" do; @prompt.user_id.should == ANONYMOUS_USER_ID end
      end
    end
  end

protected
  def sorted(items)
    items.sort_by &:id
  end
end