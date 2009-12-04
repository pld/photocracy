class Attachment < ActiveRecord::Base
  has_one :item
  has_attachment :storage => :file_system, :path_prefix => 'public/system', :content_type => :image,
                 :thumbnails => { :thumb => '100x100>',
                                  :compare => '350x350>' }

  validates_presence_of :uploaded_data, :if => lambda { |el| el.filename.nil? }
  validates_presence_of :filename, :if => lambda { |el| el.uploaded_data.nil? }
end
