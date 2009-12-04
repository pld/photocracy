require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include Constants::Params

describe Param do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :value => "value for value"
    }
  end

  it "should create a new instance given valid attributes" do
    Param.create!(@valid_attributes)
  end

  (LOGIN_REQUIRED.keys << 'invalid key').each do |key|
    describe "login required for #{key}" do
      it 'should return true for non present key' do
        Param.login_required?(key).should == true
      end

      it 'should return true if param not found' do
        Param.login_required?(key).should == true
      end

      it 'should return true if value != f' do
        Param.create(:name => LOGIN_REQUIRED[key], :value => 't')
        Param.login_required?(key).should == true
      end

      it 'should return false otherwise' do
        Param.create(:name => LOGIN_REQUIRED[key], :value => 'f')
        if key != 'invalid key'
          Param.login_required?(key).should == false
        else
          Param.login_required?(key).should == true
        end
      end
    end

    describe "find by code for #{key}" do
      before do
        @param = Param.find_by_name((LOGIN_REQUIRED[key] || key).to_sym)
      end

      it 'should return mapped by name' do
        Param.find_by_code(key).should == @param
      end

      it 'should return object' do
        Param.delete_all
        param = Param.create(:name => (LOGIN_REQUIRED[key] || key), :value => 'f')
        Param.find_by_code(key).should == param
      end
    end

    describe "create for code for #{key}" do
      it 'should create object' do
        Param.create_for_code(key, key.to_s)
        Param.find_by_code(key).value.should == key.to_s
      end

      it 'should return object' do
        param = Param.create_for_code(key, key.to_s).new_record?.should == false
      end
    end
  end

  describe 'random first question' do
    it 'should return boolean value' do
      Param.random_first_question?.should == Param.boolean(RANDOM_FIRST_QUESTION)
    end

    it 'should return set value' do
      param = Param.create(:name => RANDOM_FIRST_QUESTION, :value => 'f')
      Param.random_first_question?.should == Param.boolean(RANDOM_FIRST_QUESTION)
    end
  end

  describe 'random new question percent' do
    it 'should return 100 if no stored value' do
      Param.random_new_question_percent.should == 100.0
    end

    it 'should return 100 - stored value' do
      param = Param.create(:name => RANDOM_NEW_QUESTION_PERCENT, :value => 40)
      Param.random_new_question_percent.should == 100.0 - param.value
    end
  end

  describe 'random new question prob' do
    it 'should return 1 if no stored value' do
      Param.random_new_question_prob.should == 1.0
    end

    it 'should return value / 100' do
      param = Param.create(:name => RANDOM_NEW_QUESTION_PERCENT, :value => 40)
      Param.random_new_question_prob.should == (100.0 - param.value) / 100.0
    end
  end

  describe 'boolean' do
    it 'should return true if param not found' do
      Param.boolean('invalid').should == true
    end

    it 'should return true if value != f' do
      Param.create(:name => 'valid', :value => 't')
      Param.boolean('valid').should == true
    end

    it 'should return false otherwise' do
      Param.create(:name => 'valid', :value => 'f')
      Param.boolean('valid').should == false
    end
  end

  describe 'value named' do
    it 'should default if unset' do
      Param.value_named(REFRESH_QUESTION_AFTER, DEFAULT_REFRESH_QUESTION_AFTER).should == DEFAULT_REFRESH_QUESTION_AFTER
    end

    it 'should return value if set' do
      param = Param.create(:name => REFRESH_QUESTION_AFTER, :value => 40)
      Param.value_named(REFRESH_QUESTION_AFTER, DEFAULT_REFRESH_QUESTION_AFTER).should == param.value.to_s
    end
  end
end