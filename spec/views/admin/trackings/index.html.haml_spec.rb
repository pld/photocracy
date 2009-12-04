require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/trackings/index.html.haml" do
  fixtures :visits, :users, :trackings

  include Admin::TrackingsHelper
  
  before(:each) do
    assigns[:trackings] = Tracking.page_find
  end

  it "should render list of admin/trackings" do
    render "/admin/trackings/index.html.haml"
  end
end

