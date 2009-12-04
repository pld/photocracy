require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/profiles/show.html.haml" do
  fixtures :profiles, :profile_questions

  include ProfilesHelper
  
  before(:each) do
    assigns[:profile] = @profile = Profile.first
    @profile.profile_questions = ProfileQuestion.all
    assigns[:items] = []
  end

  it "should render attributes in <p>" do
    render "/profiles/show.html.haml"
  end
end

