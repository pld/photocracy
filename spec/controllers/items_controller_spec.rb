require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../attachment_spec_helper')

describe ItemsController do
  include AttachmentSpecHelper
  fixtures :users, :questions

  def mock_item(stubs={})
    @mock_item ||= mock_model(Item, stubs)
  end

  before do
    login_as :quentin
    question = self.question
    question.update_attribute(:question_id_ext, ActiveRecord::Base.pairwise.question(question.name).first) if question.question_id_ext == 999999999
  end

  describe 'responding to GET index' do
    it 'should assign active question' do
      get :index
      assigns[:question].should == @controller.active_question
    end

    it 'should assign questions' do
      get :index
      assigns[:questions].should == Question.find_for_items
    end

    it 'should refresh stats' do
      Item.should_receive(:refresh_stats).exactly(Question.find_for_items.length).times
      get :index
    end

    it 'should prep paginate' do
      @controller.should_receive(:paginate_prep)
      get :index
    end
  end

  describe 'responding to list' do
    before do
      @params = { :question_id => Question.first.id }
      get :list, @params
    end

    it 'should assign question' do
      assigns[:question].should == Question.find(@params[:question_id])
    end

    it 'should assign order default if no pass' do
      request.session[:order].should == 'items_questions.position desc'
    end
  end

  describe "responding to GET show" do
    it "should expose the requested item as @item" do
      Item.should_receive(:find).with("37", :conditions => { :active => true }).and_return(mock_item)
      get :show, :id => "37"
      assigns[:item].should equal(mock_item)
    end

    describe "with mime type of xml" do
      it "should render the requested item as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Item.should_receive(:find).with("37", :conditions => { :active => true }).and_return(mock_item)
        mock_item.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end
    end
  end

  describe "responding to GET new" do
    it "should expose a new item as @item" do
      Item.should_receive(:new).and_return(mock_item)
      get :new
      assigns[:item].should equal(mock_item)
    end
  end

  describe "responding to POST create" do
    describe "with valid params" do
      it "should expose a newly created item as @item" do
        post :create, valid_item
        assigns(:item).name.should == valid_item[:item][:name]
        assigns(:item).questions.each { |question| valid_item[:question].values.should include(question.question_id_ext) }
        # since this is background processed these may not be assigned yet
        # assigns(:item).item_id_ext.should_not == nil
        # assigns(:item).attachment_id.should_not == nil
        # assigns(:item).visit_id.should_not == nil
      end

      it "should redirect to the created item" do
        post :create, valid_item
        response.should redirect_to('/')
      end
    end
    
    describe "with invalid params" do
      it "should expose a newly created but unsaved item as @item" do
        post :create, invalid_item(:uploaded_data)
        assigns(:item).name.should == valid_item[:item][:name]
        assigns(:item).new_record?.should == true
      end

      it "should re-render the 'new' template" do
        post :create, invalid_item(:uploaded_data)
        response.should render_template('new')
      end

      it "should require agree" do
        post :create, invalid_item(:agree)
        assigns(:item).name.should == valid_item[:item][:name]
        assigns(:item).errors["agree"].should_not == nil
        assigns(:attachment).errors["uploaded_data"].should == nil
      end

      it "should require uploaded_data" do
        post :create, invalid_item(:uploaded_data)
        assigns(:item).errors["agree"].should == nil
        assigns(:attachment).errors["uploaded_data"].should_not == nil
      end

      it "should require agree and uploaded_data" do
        post :create, invalid_item([:uploaded_data, :agree])
        assigns(:item).errors["agree"].should_not == nil
        assigns(:attachment).errors["uploaded_data"].should_not == nil
      end
    end
  end

  describe 'flag' do
    describe 'comment' do
      before do
        @comment = Comment.create!(:item_id => 1, :visit_id => 1, :content => 'text')
        @params = { :flag => { :flag_type_id => "1", :comment_id => @comment.id } }
      end

      it 'should fail with invalid params' do
        post :flag, :flag => {}
      end

      it 'should create flag for comment' do
        post :flag, @params
        Flag.find_by_comment_id(@comment.id).should_not == nil
      end

      it 'should redirect' do
        post :flag, @params
        response.should redirect_to item_path(@comment.item_id)
      end
    end

    describe 'item' do
      before do
        @item = Item.first
        @params = { :flag => { :flag_type_id => "1", :item_id => @item.id } }
      end

      it 'should fail with invalid params' do
        post :flag, :flag => {}
      end

      it 'should create flag for item' do
        post :flag, @params
        Flag.find_by_item_id(@item.id).should_not == nil
      end

      it 'should redirect' do
        post :flag, @params
        response.should redirect_to items_path
      end
    end
  end

  describe 'comment' do
    before do
      @item_id = 100
      @controller.active_visit = Visit.create(:ip_address => '1122')
      @params = { :comment => { 'item_id' => @item_id, 'content' => 'content'} }
      @comment = mock_model(Comment)
      @comment.should_receive(:save)
    end

    if Constants::Params::NO_MODERATE_COMMENTS
      it 'should set visit' do
        Comment.should_receive(:new).with(@params[:comment].merge('visit_id' => @controller.active_visit.id)).and_return(@comment)
        @comment.errors.should_receive(:full_messages)
        post :comment, @params
      end
    else
      it 'should set comment inactive and visit' do
        Comment.should_receive(:new).with(@params.merge('active' => false, 'visit_id' => @controller.active_visit.id)).and_return(@comment)
        @comment.errors.should_receive(:full_messages)
        post :comment, @params
      end
    end
  end

  describe 'send to friend' do
    before do
      @params = { :mailing => { 'name' => 'jo', 'email' => 'jo@jo.com', 'message' => 'jo' } }
      @mailing = mock_model(Mailing)
    end

    it 'should create mailing' do
      @mailing.should_receive(:save)
      Mailing.should_receive(:new).with(@params[:mailing].merge('user_id' => current_user.id)).and_return(@mailing)
      @mailing.errors.should_receive(:full_messages)
      post :share, @params
    end
  end

  describe 'paginate' do
    fixtures :questions

    before do
      @question = Question.first
    end

    it 'should get question' do
      Question.should_receive(:find).with(@question.id.to_s).and_return(@question)
      post :paginate, :id => @question.id
    end

    it 'should set question' do
      post :paginate, :id => @question.id
      assigns[:question].should == @question
    end

    it 'should assign page' do
      post :paginate, :id => @question.id, :page => 2
      assigns[:page].should == '2'
    end
  end

  describe 'country' do
    fixtures :questions

    before do
      @question = Question.first
    end

    it 'should get question' do
      Question.should_receive(:find).with(@question.id.to_s).and_return(@question)
      post :country, :question_id => @question.id, :country_id => 'bo'
    end

    it 'should join nil if not priority country' do
      post :country, :question_id => @question.id, :country_id => 'All Countries'
      assigns[:joins].should == nil
    end

    it 'should join country' do
      post :country, :question_id => @question.id, :country_id => 'JP'
      assigns[:country_code].should == "JP"
    end
  end

protected
  def question
    Question.find(1)
  end

private
  def valid_item
    { :item => { :name => 'name', :agree => "1" }, :attachment => { :uploaded_data => uploaded_data }, :question => { :id1 => question.question_id_ext, :id2 => question.question_id_ext } }
  end

  def invalid_item(vars)
    item = valid_item
    [vars].flatten.each do |var|
      item[:item].delete(var)
      item[:attachment].delete(var)
    end
    item
  end
end