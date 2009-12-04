class MockUpload
  # The filename, *not* including the path, of the "uploaded" file
  attr_reader :original_filename

  # The content type of the "uploaded" file
  attr_reader :content_type

  def initialize(path, content_type = Mime::TEXT)
    raise "#{path} file does not exist" unless File.exist?(path)
    @content_type = content_type
    @original_filename = path.sub(/^.*#{File::SEPARATOR}([^#{File::SEPARATOR}]+)$/) { $1 }
    @tempfile = Tempfile.new(@original_filename)
    FileUtils.copy_file(path, @tempfile.path)
  end

  def path #:nodoc:
    @tempfile.path
  end

  alias local_path path

  def method_missing(method_name, *args, &block) #:nodoc:
    @tempfile.send(method_name, *args, &block)
  end
end