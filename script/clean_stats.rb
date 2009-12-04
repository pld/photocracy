to_keep = []
to_delete = Stat.all.inject([]) do |array, stat|
  seen = to_keep + array
  conditions = "
    item_id=#{stat.item_id} AND
    question_id=#{stat.question_id} AND
    group_id=#{stat.group_id}"
  conditions += " AND id NOT IN (#{seen.join(',')})" unless seen.empty?
  stats = Stat.all(:conditions =>  conditions) - [stat]
  to_keep << stat.id
  stats.empty? ? array : array + stats.map(&:id)
end
Stat.delete_all(:id => to_delete)