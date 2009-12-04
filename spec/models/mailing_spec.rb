require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Mailing do
  fixtures :users

  before(:each) do
    @valid_attributes = {
      :user_id => User.first.id,
      :name => 'name',
      :email => 'email@email.com',
      :message => "value for message"
    }
  end

  it "should create a new instance given valid attributes" do
    Mailing.create!(@valid_attributes)
  end

  describe 'send mail' do
    it 'should send mail on create' do
      UserMailer.should_receive(:deliver_item)
      mailing = Mailing.create!(@valid_attributes)
    end

    it 'should set sent on create' do
      mailing = Mailing.create!(@valid_attributes)
      mailing.sent.should == true
    end

    it 'should not send mail on update' do
      mailing = Mailing.create!(@valid_attributes)
      UserMailer.should_not_receive(:deliver_item)
      mailing.update_attribute :sent, false
      mailing.update_attribute :name, 'false'
      mailing.sent.should == false
    end

    it 'should not send mail on create if sent is true' do
      UserMailer.should_not_receive(:deliver_item)
      Mailing.create!(@valid_attributes.merge(:sent => true))
    end
  end
end
