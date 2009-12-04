require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Tracking do
  before(:each) do
    @valid_attributes = {
      :visit_id => "1",
      :controller => "value for controller",
      :action => "value for action",
      :parameters => "value for parameters"
    }
  end

  it "should create a new instance given valid attributes" do
    Tracking.create!(@valid_attributes)
  end
end
