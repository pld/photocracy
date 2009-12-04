FILE_LOC="/Users/kg/Sites/princeton/data/csv/jw_tag_list.csv"

COUNTRY = 0
ID = 1
TAGS = 2
data = IO.readlines(FILE_LOC)[0].split("\r")
data.shift
missing = []
data.each do |el|
  row = el.split(',')
  question = Question.find(row.shift)
  id = row.shift
  begin
    if id.to_i > 0
      flickr = Flickr.find_by_photo_id(id)
      item = (flickr && flickr.item) || Item.first(:conditions => "external_link LIKE '%#{id}%'")
    else
      item = Item.first(:conditions => "external_link LIKE '%{id}%'")
    end
    raise if item.nil?
    tags = row.reject { |tag| tag == '0' }.join(', ')
    item.set_tag_list_on(question.groups.first.code.to_sym, tags)
    item.save
    puts item.reload.tags_on(question.groups.first.code.to_sym)
  rescue
    missing << id
  end
end
puts missing.inspect