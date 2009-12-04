require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProfileQuestion do
  before(:each) do
    @valid_attributes = {
      :profile_id => 1,
      :name => "value for name",
      :value => "value for value"
    }
  end

  it "should create a new instance given valid attributes" do
    ProfileQuestion.create!(@valid_attributes)
  end
end
