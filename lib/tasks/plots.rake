namespace :plot do
  desc 'Sync and build all plots'
  task :all => ['plot:sync', 'plot:stats']
  task :analytics => ['plot:sync', 'plot:usage']

  desc 'Usage plots and data'
  task :usage => :environment do
    plot = Plot.new(Constants::Config::Admin::Paths::PLOT)
    plot.data
    plot.usage
  end

  desc 'Item plots'
  task :items => :environment do
    plot = Plot.new(Constants::Config::Admin::Paths::PLOT)
    plot.items
  end

  desc 'All stat plots'
  task :stats => :environment do
    plot = Plot.new(Constants::Config::Admin::Paths::PLOT)
    plot.items
    plot.data
    plot.usage
  end
  
  desc 'Build per item plots'
  task :items => :environment do
    Plot.new(Constants::Config::Admin::Paths::PLOT).items
  end

  desc 'Sync vote'
  task :sync => :environment do
    Systems::Syncing.deactivate_admin_responses
    Systems::Syncing.update_cache
  end

  desc 'Build data stats'
  task :data => :environment do
    ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
    Plot.new(Constants::Config::Admin::Paths::PLOT).data
  end

  desc "Build usage plots"
  task :usage => :environment do
    ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
    Plot.new(Constants::Config::Admin::Paths::PLOT).usage
  end
end