require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/trackings/show.html.haml" do
  fixtures :visits, :users

  include Admin::TrackingsHelper
  
  before(:each) do
    assigns[:tracking] = @tracking = stub_model(Tracking,
      :visit_id => Visit.first,
      :controller => "value for controller",
      :action => "value for action",
      :parameters => "value for parameters",
      :created_at => Time.now.to_s(:db)
    )
  end

  it "should render attributes in <p>" do
    render "/admin/trackings/show.html.haml"
    response.should have_text(/value\ for\ controller/)
    response.should have_text(/value\ for\ action/)
    response.should have_text(/value\ for\ parameters/)
  end
end

