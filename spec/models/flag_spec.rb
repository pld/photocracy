require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include Constants::Flags

describe Flag do

  fixtures :comments, :flag_types, :items

  before(:each) do
    @valid_attributes = {
      :item_id => "1",
      :visit_id => "1",
      :flag_type_id => "1"
    }
  end

  it 'should create a new instance given valid attributes' do
    Flag.create!(@valid_attributes)
  end

  describe 'count_active' do
    before do
      @item = Item.first
      @item.flags << Array.new(4) { Flag.create(:item => @item, :visit_id => 1, :flag_type_id => 1) }
    end

    it 'should count flags' do
      Flag.count_active.should == 4
      @item.flags.count_active.should == 4
    end

    it 'should only count active flags' do
      @item.flags << Array.new(4) { Flag.create(:item => @item, :visit_id => 1, :flag_type_id => 1, :active => false) }
      Flag.count_active.should == 4
      @item.flags.count_active.should == 4
    end
  end

  describe 'counting uniq ips' do
    before do
      @ip = '111112'
      @visit = Visit.create(:ip_address => @ip)
      @item = Item.first
      @comment = Comment.first
      @flag = Flag.create(:flag_type => FlagType.first, :visit => @visit, :item => @item)
    end

    it 'should count for only item if item passed' do
      10.times { Flag.create(:flag_type => FlagType.first, :visit => @visit, :item => @item) }
      10.times { Flag.create(:flag_type => FlagType.first, :visit => @visit, :item => Item.last) }
      Flag.uniq_ip_count(@item).should == 1
    end

    it 'should count item flags high' do
      10.times { Flag.create(:flag_type => FlagType.first, :visit => unique_ip_visit, :item => @item) }
      Flag.uniq_ip_count(@item).should == 11
    end

    it 'should count for only comment if comment passed' do
      10.times { Flag.create(:flag_type => FlagType.first, :visit => @visit, :comment => @comment) }
      10.times { Flag.create(:flag_type => FlagType.first, :visit => @visit, :comment => Comment.last) }
      Flag.uniq_ip_count(@comment).should == 1
    end

    it 'should count item flags high' do
      10.times { Flag.create(:flag_type => FlagType.first, :visit => unique_ip_visit, :comment => @comment) }
      Flag.uniq_ip_count(@comment).should == 10
    end

    it 'should count all flags if something else passed' do
      10.times do
        Flag.create(:flag_type => FlagType.first, :visit => @visit, :item => @item)
        Flag.create(:flag_type => FlagType.first, :visit => @visit, :comment => @comment)
      end
      Flag.uniq_ip_count(nil).should == 1
    end

    it 'should count all flags if something else passed with different visits' do
      10.times do
        Flag.create(:flag_type => FlagType.first, :visit => @visit, :item => @item)
        Flag.create(:flag_type => FlagType.first, :visit => unique_ip_visit, :comment => @comment)
      end
      Flag.uniq_ip_count(nil).should == 11
    end

    it 'should count all flags high if something else passed' do
      10.times do
        Flag.create(:flag_type => FlagType.first, :visit => unique_ip_visit, :item => @item)
        Flag.create(:flag_type => FlagType.first, :visit => unique_ip_visit, :comment => @comment)
      end
      Flag.uniq_ip_count(nil).should == 21
    end

    it 'should count both inactive and active flags by default' do
      10.times do
        Flag.create(:flag_type => FlagType.first, :visit => unique_ip_visit, :item => @item, :active => false)
        Flag.create(:flag_type => FlagType.first, :visit => unique_ip_visit, :comment => @comment, :active => false)
      end
      Flag.uniq_ip_count(nil).should == 21
    end

    it 'should count both active flags when passed' do
      10.times do
        Flag.create(:flag_type => FlagType.first, :visit => unique_ip_visit, :item => @item, :active => false)
        Flag.create(:flag_type => FlagType.first, :visit => unique_ip_visit, :comment => @comment, :active => false)
      end
      Flag.uniq_ip_count(nil, true).should == 1
    end

    it 'should count all flags when passed' do
      10.times do
        Flag.create(:flag_type => FlagType.first, :visit => unique_ip_visit, :item => @item, :active => false)
        Flag.create(:flag_type => FlagType.first, :visit => unique_ip_visit, :comment => @comment, :active => false)
      end
      Flag.uniq_ip_count(nil, false).should == 21
    end
  end

  describe 'supending from flag' do
    describe 'for item' do
      before do
        @item = Item.first
        @item.activate
        (DEFAULT_ITEM_FLAGS_FOR_SUSPEND - 1).times do 
          @flag = Flag.create(:flag_type => FlagType.first, :visit => unique_ip_visit, :item => @item)
        end
      end

      it 'should not suspend if ip < default' do
        @flag.suspend
        @flag.item.should == @item
        @flag.item.active.should == true
      end

      it 'should not suspend if uniq ip < default' do
        @flag = Flag.create(:flag_type => FlagType.first, :visit => @flag.visit, :item => @item)
        @flag.suspend
        @flag.item.active.should == true
      end

      it 'should suspend if uniq ip flags == default' do
        @flag = Flag.create(:flag_type => FlagType.first, :visit => unique_ip_visit, :item => @item)
        @flag.suspend
        @flag.item.active.should == false
      end

      it 'should suspend if uniq ip flags > default' do
        2.times do 
          @flag = Flag.create(:flag_type => FlagType.first, :visit => unique_ip_visit, :item => @item)
        end
        @flag.suspend
        @flag.item.active.should == false
      end

      describe 'after setting param' do
        before do
          @more = 5
          Param.create(:name => ITEM_FLAGS_FOR_SUSPEND, :value => DEFAULT_ITEM_FLAGS_FOR_SUSPEND + @more)
        end

        it 'should not suspend if uniq ip < default' do
          @more.times do 
            @flag = Flag.create(:flag_type => FlagType.first, :visit => unique_ip_visit, :item => @item)
          end
          @flag.suspend
          @flag.item.active.should == true
        end

        it 'should suspend if uniq ip >= default' do
          (@more + 1).times do 
            @flag = Flag.create(:flag_type => FlagType.first, :visit => unique_ip_visit, :item => @item)
          end
          @flag.suspend
          @flag.item.active.should == false
        end

        it 'should suspend based on active and inactive flags by default' do
          (@more + 1).times do 
            @flag = Flag.create(:flag_type => FlagType.first, :visit => unique_ip_visit, :item => @item, :active => false)
          end
          @flag.suspend
          @flag.item.active.should == false
        end

        describe 'suspend based on active flags if passed' do
          it 'should be active if inactive flags' do
            (@more + 1).times do
              @flag = Flag.create(:flag_type => FlagType.first, :visit => unique_ip_visit, :item => @item, :active => false)
            end
            @flag.suspend(true)
            @flag.item.active.should == true
          end

          it 'should be inactive if active flags' do
            (@more + 1).times do
              @flag = Flag.create(:flag_type => FlagType.first, :visit => unique_ip_visit, :item => @item, :active => true)
            end
            @flag.suspend(true)
            @flag.item.active.should == false
          end
        end

        it 'should count all flags when passed' do
          (@more + 1).times do
            @flag = Flag.create(:flag_type => FlagType.first, :visit => unique_ip_visit, :item => @item, :active => false)
          end
          @flag.suspend(false)
          @flag.item.active.should == false
        end
      end
    end

    describe 'for comment' do
      before do
        @comment = Comment.first
        @comment.activate
        (DEFAULT_COMMENT_FLAGS_FOR_SUSPEND - 1).times do 
          @flag = Flag.create(:flag_type => FlagType.first, :visit => unique_ip_visit, :comment => @comment)
        end
      end

      it 'should not suspend if ip < default' do
        @flag.suspend
        @flag.comment.should == @comment
        @flag.comment.active.should == true
      end

      it 'should not suspend if uniq ip < default' do
        @flag = Flag.create(:flag_type => FlagType.first, :visit => @flag.visit, :comment => @comment)
        @flag.suspend
        @flag.comment.active.should == true
      end

      it 'should suspend if uniq ip flags == default' do
        @flag = Flag.create(:flag_type => FlagType.first, :visit => unique_ip_visit, :comment => @comment)
        @flag.suspend
        @flag.comment.should == @comment
        @flag.comment.active.should == false
      end

      it 'should suspend if uniq ip flags > default' do
        3.times do 
          @flag = Flag.create(:flag_type => FlagType.first, :visit => unique_ip_visit, :comment => @comment)
        end
        @flag.suspend
        @flag.comment.active.should == false
      end

      describe 'after setting param' do
        before do
          @more = 5
          Param.create(:name => COMMENT_FLAGS_FOR_SUSPEND, :value => DEFAULT_COMMENT_FLAGS_FOR_SUSPEND + @more)
        end

        it 'should not suspend if uniq ip < default' do
          @more.times do 
            @flag = Flag.create(:flag_type => FlagType.first, :visit => unique_ip_visit, :comment => @comment)
          end
          @flag.suspend
          @flag.comment.active.should == true
        end

        it 'should suspend if uniq ip >= default' do
          (@more + 1).times do 
            @flag = Flag.create(:flag_type => FlagType.first, :visit => unique_ip_visit, :comment => @comment)
          end
          @flag.suspend
          @flag.comment.active.should == false
        end
      end
    end
  end

protected
  def unique_ip_visit
    ips = Visit.all.map { |v| v.ip_address }
    while ips.include?(ip = rand.to_s) do; end
    Visit.create(:ip_address => ip)
  end
end