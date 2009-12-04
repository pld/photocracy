module Systems::Syncing
  module_function
    def deactivate_admin_responses
      response_ids = Response.all(
        :select => 'responses.id',
        :joins => "INNER JOIN visits ON responses.visit_id=visits.id INNER JOIN users ON (visits.user_id=users.id AND users.state LIKE 'admin')",
        :conditions => "active=1 AND users.state LIKE 'admin'",
        :group => 'responses.id'
      ).map(&:id)
      Response.update_all("active=0", "responses.active=1 AND responses.id IN (#{response_ids.join(',')})") unless response_ids.empty?
      response_ids
    end
  
    def update_cache
      ItemsQuestion.transaction do
        ItemsQuestion.all(:include => :item).each do |iq|
          next if iq.item.nil?
          wins = iq.item.wins(iq.question_id, '')
          ratings = iq.item.ratings(iq.question_id)
          losses = ratings - wins
          iq.update_attributes(:wins => wins, :ratings => ratings, :losses => losses)
        end
      end
    end
end