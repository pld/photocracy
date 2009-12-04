class Admin::AnalyticsController < Admin::BaseController

  def index
    @path = Constants::Config::Admin::Paths::PLOT
    @all = Constants::Config::Admin::LOCATIONS

    @visits_to_voters, @visits_to_register, @visits_to_interact = {}, {}, {}
    @all.each do |loc|
      @visits_to_voters[loc] = Param.data_load("#{loc}visits_to_voters")
      @visits_to_register[loc] = Param.data_load("#{loc}visits_to_register")
      @visits_to_interact[loc] = Param.data_load("#{loc}visits_to_interact")
    end
  end

  def items
    @path = Constants::Config::Admin::Paths::PLOT
    @items = Item.page_find(params[:page])
  end

  def items_use
    @all = Constants::Config::Admin::LOCATIONS
    @path = Constants::Config::Admin::Paths::PLOT
    @lasts = count_percents(load_items(:last).to_hash).first(50)
    @skips = count_percents(load_items(:skipped).to_hash).first(50)
  end

private
  def count_percents(hash)
    Item.find(hash.keys).map do |item|
      num = hash[item.id]
      # id => [item, num, percent]
      [item, num, 100 * (num.to_f / item.prompts.count(:conditions => { :active => false }))]
    end.sort_by { |array| -array.last }
  end

  def load_items(type)
    name = "#{Constants::Config::Admin::Paths::DATA}#{type}.yml"
    File.exists?(name) ? YAML.load(File.open(name, 'r') { |file| file.read }) : []
  end
end