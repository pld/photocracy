module Systems::Flickr
  def data_for_flickr_id(id, require_geo_info = false)
    begin
      info = flickr.photos.getInfo(:photo_id => id)
    rescue FlickRaw::FailedResponse
      return false
    end
    item = {
      :description => info.description,
      :attribution => info.owner.username,
      :external_link => info.urls.detect { |el| el.type == 'photopage' }._content
    }

    flickr = {
      :title => info.title,
      :num_comments => info.comments,
      :license_id => info.license,
      :posted => info.dates.posted,
      :lastupdate => info.dates.lastupdate,
      :taken => info.dates.taken,
      :tags => info.tags.map(&:raw).join(';'),
      :description => info.description,
      :username => info.owner.username,
      :photo_id => id,
    }
    if info.respond_to?(:location)
      flickr.merge!(:longitude => info.location.longitude) if info.location.respond_to?(:longitude)
      flickr.merge!(:latitude => info.location.latitude) if info.location.respond_to?(:latitude)
      flickr.merge!(:accuracy => info.location.accuracy) if info.location.respond_to?(:accuracy)
      flickr.merge!(:country => info.location.country) if info.location.respond_to?(:country)
      flickr.merge!(:place_id => info.location.place_id) if info.location.respond_to?(:place_id)
      flickr.merge!(:region => info.location.region.to_s)  if info.location.respond_to?(:region)
    elsif require_geo_info
      return false
    end
    [item, flickr]
  end

  # flickr upload
  def temp_file_for_flickr_id(id)
    sizes = flickr.photos.getSizes(:photo_id => id)
    url = (sizes.detect { |el| el.label == 'Medium' } || sizes.detect { |el| el.label == 'Original' }).source
#    path = "#{Constants::Config::DIR_PATH}/#{File.basename(url)}"
#    %x(curl -s -o #{path} #{url})
    temp_file_for_url(url)
  end
end