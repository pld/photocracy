module Admin::HomeHelper
def google_map_visits
    geos = Visit.all(
      :joins => "LEFT OUTER JOIN users ON (visits.user_id=users.id)",
      :conditions => "users.state != 'admin'",
      :order => "visits.created_at DESC",
      :limit => 500,
      :select => "ip_latitude, ip_longitude"
    ).inject([]) do |array, visit|
      geo = [visit.ip_latitude, visit.ip_longitude]
      unless geo.any? { |pos| pos.nil? }
        array << geo.join(',')
      end
      array
    end
    geos = geos.length > 0 ? "[#{geos.join('],[')}]" : ''
    javascript_tag("Google.map([#{geos}], [], 'visit_map')")
  end
end
