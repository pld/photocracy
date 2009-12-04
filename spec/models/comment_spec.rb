require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Comment do
  before(:each) do
    @valid_attributes = {
      :item_id => "1",
      :visit_id => "1",
      :content => "value for content",
      :active => false
    }
  end

  it 'should create a new instance given valid attributes' do
    Comment.create!(@valid_attributes)
  end

  it 'should sanitize content' do
    comment = Comment.create!(@valid_attributes.merge(:content => '<a href="http">link!</a>'))
    comment.content.should have_text('link!')
    comment.content.should_not have_text('</a>')
    comment.content.should_not have_text('<a href="http">')
  end

  it 'should suspend comment' do
    comment = Comment.create!(@valid_attributes)
    comment.activate
    comment.suspend
    comment.active.should == false
  end

  it 'should activate comment' do
    comment = Comment.create!(@valid_attributes)
    comment.suspend
    comment.activate
    comment.active.should == true
  end

  describe 'ordered_active' do
    before do
      15.times { Comment.create!(@valid_attributes.merge(:created_at => Time.now.to_s(:db))) }
      @comments = Comment.ordered_active
    end

    it 'should return active only' do
      @comments.each { |comment| comment.active.should == true }
    end

    it 'should order by created desc' do
      last = nil
      @comments.each do |comment|
        comment.created_at < last.created_at if last
        last = comment
      end
    end
  end
end
