require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Profile do
  before(:each) do
    @valid_attributes = {
      :user_id => "1",
      :country => "value for langauge"
    }
  end

  it "should create a new instance given valid attributes" do
    Profile.create!(@valid_attributes)
  end
end
