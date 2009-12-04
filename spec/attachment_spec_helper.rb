require File.expand_path(File.dirname(__FILE__) + '/mock_upload')

module AttachmentSpecHelper
  def uploaded_data
    MockUpload.new File.expand_path(File.dirname(__FILE__) + '/fixtures/data/empty.jpg')
  end
end