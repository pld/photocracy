require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Attachment do
  it 'should require require uploaded_data' do
    lambda { Attachment.create! }.should raise_error(ActiveRecord::RecordInvalid)
  end
end
