require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Visit do
  before(:each) do
    @valid_attributes = {
      :ip_address => "value for ip_address"
    }
  end

  it "should create a new instance given valid attributes" do
    Visit.create!(@valid_attributes)
  end
end
