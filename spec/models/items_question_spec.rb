require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ItemsQuestion do
  before(:each) do
    @valid_attributes = {
      :item_id => 1,
      :question_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    ItemsQuestion.create!(@valid_attributes)
  end

  # describe 'saving wins' do
  #   before do
  #     @perc = 100 * (50 / 70.0)
  #     @iq = ItemsQuestion.create!(@valid_attributes.merge(:wins => 50, :ratings => 70))
  #   end
  # 
  #   it 'should format win percent' do
  #     @iq.win_percent.should == 5046
  #   end
  # 
  #   it 'should format percent_wins' do
  #     @iq.win_percentage.should == 50.46
  #   end
  # 
  #   it 'should update attribute' do
  #     @iq.update_attributes!({ :percent_wins => 25.23 })
  #     @iq.reload.win_percent.should == 2523
  #     @iq.win_percentage.should == 25.23
  #   end
  # end
end
