require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do

  describe 'top country item' do
    fixtures :items, :questions

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
      @items = [@item, @item2]
      @user = User.first
      visit = Visit.create!(:ip_address => '12')
      i = (Prompt.last) ? Prompt.last.prompt_id_ext : 0
      [@question, @question2].each do |question|
        20.times do
          country = (i % 2).zero? ? 'US' : 'CN'
          prompt = Prompt.create!(:prompt_id_ext => i + 1, :question => question, :user => @user)
          prompt.items << @item << @item2
          response = Response.create!(:visit => visit, :prompt => prompt, :vote_id_ext => i + 1, :response_time => 15, :ip_country_code => country)
          response.items << ((i % 2).zero? ? @item : @item2) if (i % 2).zero?
          i += 1
        end
      end
    end

    it 'should return item with most wins for passed country' do
      helper.top_country_item('us', @items, @question).should == @item
    end
  end
end
