require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Question do
  before(:each) do
    @valid_attributes = {
      :question_id_ext => "1",
      :name => "value for name"
    }
  end

  describe 'remoting' do
    it 'should get a remote id on validation' do
      Question.create!(@valid_attributes).question_id_ext.should_not == nil
    end
  end

  describe 'find for items' do
    it 'should order by arg' do
      order = 'items_questions.position desc'
      Question.should_receive(:find).with(:all, :include => [:items], :conditions => { 'items.active' => true }, :order => order)
      Question.find_for_items(order)
    end
  end

  describe 'random' do
    fixtures :questions

    it 'should return a random question given conditions arg' do
      conditions = 'id IN (1)'
      Question.all(conditions).should include(Question.random(conditions))
    end
  end
end