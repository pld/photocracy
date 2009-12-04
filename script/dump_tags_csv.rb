items = Item.all(:include => { :questions => :groups })

File.open('tags.csv', 'w') do |file|
  file.write("photo_id\tquestion_id\ttags\n")
  for item in items
    questions = item.questions
    for question in questions
      tags = item.tag_list_on(question.groups.first.code.to_sym)
      file.write("#{item.id}\t#{question.id}\t#{tags.join(',')}\n") unless tags.empty?
    end
  end
end