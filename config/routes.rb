ActionController::Routing::Routes.draw do |map|
  map.error '/error',     :controller => 'home', :action => 'error'
  map.about '/about',     :controller => 'home', :action => 'index'
  map.stats '/stats',     :controller => 'home', :action => 'stats'
  map.feedback '/feedback', :controller => 'home', :action => 'feedback'
  map.privacy '/privacy', :controller => 'home', :action => 'privacy'
  map.share '/share',     :controller => 'home', :action => 'share'
  map.resources :items, { :member => [:image => :get] }
  #, :member => { :paginate => [:get, :post], :requirements => { :page => /\d+/ }, :page => nil }
  # map.connect 'items/paginate/:page',
  #     :controller => 'items',
  #     :action => 'paginate',
  #     :requirements => { :page => /\d+/},
  #     :page => nil
  map.resources :profiles, :collection => { :language => :post }
  map.connect('language/:id/:q', :controller => 'profiles', :action => 'language', :defaults => { :q => 0, :id => 'en' })
  map.resources :responses
  map.logout '/logout',     :controller => 'sessions', :action => 'destroy'
  map.login '/login',       :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup',     :controller => 'users', :action => 'new'
  map.forgot '/forgot',     :controller => 'users', :action => 'forgot'
  map.denied '/denied',     :controller => 'sessions', :action => 'denied'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  map.reset '/reset/:activation_code', :controller => 'users', :action => 'reset', :activation_code => nil
  map.resource :session
  map.resources :users, :collection => { :profile => [:get, :post] }

  map.namespace :admin do |admin|
    admin.analytics 'analytics', :controller => 'analytics', :action => 'index'
    admin.settings 'settings', :controller => 'home', :action => 'settings'
    admin.resources :comments
    admin.resources :experiments
    admin.resources :flag_types
    admin.resources :flags
    admin.resources :groups
    admin.resources :items, :collection => { :flick => [:get, :post], :flagged => :get }
    admin.resources :prompts
    admin.resources :questions
    admin.resources :responses
    admin.resources :trackings
    admin.resources :visits, :collection => { :locate => [:get] }
    admin.resources :users, :member => { :admin     => :get,
                                         :active    => :get,
                                         :suspend   => :get,
                                         :unsuspend => :get,
                                         :purge     => :delete }
  end

  map.root :controller => 'responses', :action => 'show'
  map.admin '/admin', :controller => 'admin/home'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
#  map.connect '*id', :controller => 'home', :action => 'error'
end
