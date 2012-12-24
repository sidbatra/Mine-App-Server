ActionController::Routing::Routes.draw do |map|

  map.root :controller  => :home,
    :action => :show

  map.home 'home/:id', 
    :controller => :home, 
    :action => :show
    
  map.home_sample 'home/samples/:id',
  	:controller => :home,
  	:acton => :index

  map.create_user 'create_user',
    :controller => :users,
    :action => :create

  map.logout 'logout.:format',
    :controller => :session,
    :action     => :destroy

  map.connect '/auth/google/callback',
    :controller => :google,
    :action => :create

  map.connect '/auth/google/failure',
    :controller => :google,
    :action => :create

  map.connect '/auth/yahoo/callback',
    :controller => :yahoo,
    :action => :create

  map.connect '/auth/yahoo/failure',
    :controller => :yahoo,
    :action => :create

  map.yh_auth 'yahoo/authenticate',
    :controller => :yahoo,
    :action => :new

  map.yh_reply '/yahoo/reply',
    :controller => :yahoo,
    :action => :create

  map.fb_auth 'facebook/authenticate',
    :controller => :facebook,
    :action     => :new

  map.fb_reply 'facebook/reply',
    :controller => :facebook,
    :action     => :create

  map.tw_auth 'twitter/authenticate',
    :controller => :twitter,
    :action     => :new

  map.tw_reply 'twitter/reply',
    :controller => :twitter,
    :action     => :create

  map.tumblr_auth 'tumblr/authenticate',
    :controller => :tumblr,
    :action     => :new

  map.tumblr_reply 'tumblr/reply',
    :controller => :tumblr,
    :action     => :create
  
  map.user_suggestions '/users/suggestions',
    :controller => :users,
    :action => :index,
    :aspect => "suggestions"

  ##
  # Resoure based routes
  ##
  map.resources :users,
    :only => [:create,:index,:show,:update]

  map.connections ':handle/connections',
    :controller => :users,
    :action     => :index,
    :aspect     => "connections"

  map.resource :feed,
    :controller => :feed,
    :only => [:show]

  map.short_purchase '/p/:purchase_id.:format',
    :controller => :purchases,
    :action => :show

  map.purchase ':user_handle/p/:purchase_handle',
    :controller => :purchases,
    :action     => :show

  map.edit_purchase ':user_handle/p/:purchase_handle/edit',
    :controller => :purchases,
    :action     => :edit

  map.resources :purchases,
    :only => [:index,:create,:update,:destroy],
    :collection => {:update_multiple => :put}

  map.unapproved_purchases 'purchases/unapproved',
    :controller => :purchases,
    :action     => :index,
    :aspect     => "unapproved_ui"

  #map.store 's/:handle',
  #  :controller => :stores,
  #  :action     => :show

  map.resources :stores,
    :only => [:index]

  map.resources :comments,
    :only => [:create,:index]

  map.resources :likes,
    :only => [:create]

  map.resources :followings,
    :only => [:create,:index,:show,:destroy]

  map.resources :searches,
    :only => [:create]

  map.resources :products,
    :only => [:index]

  map.resources :suggestions,
    :only => [:index]

  map.resources :facebook_subscriptions,
    :only => [:index,:create]

  map.new_invite 'invite',
    :controller => :invites,
    :action     => :new

  map.invite 'invites/:invited_by',
    :controller => :home,
    :action => :show

  map.resources :invites,
    :only => [:create]

  map.resources :contacts,
    :only => [:index]

  map.resources :notifications,
    :only => [:index,:update]

  map.resources :welcome,
    :only       => [:show,:create],
    :controller => :welcome

  map.resources :settings,
    :only => [:index,:update,:show]

  map.resource :status,
    :controller => :status,
    :only => [:show]

  map.resource :hotmail,
    :controller => :hotmail,
    :only => [:create]


  ##
  # Routes for static pages
  ##
  map.privacy 'privacy',
    :controller => :static,
    :action     => :show,
    :aspect     => :privacy

  map.terms 'terms',
    :controller => :static,
    :action     => :show,
    :aspect     => :terms

  map.copyright 'copyright',
    :controller => :static,
    :action     => :show,
    :aspect     => :copyright

  map.about 'about',
    :controller => :static,
    :action     => :show,
    :aspect     => :about

  map.faq 'faq',
    :controller => :static,
    :action     => :show,
    :aspect     => :faq


  ##
  # Admin namespace routes routes
  ##

  map.logged_exceptions 'admin/logged_exceptions/:action/:id', 
    :controller => 'logged_exceptions'

  map.admin 'admin',
    :controller => 'admin/help',
    :action     => :show

  map.namespace(:admin) do |admin|
    admin.resources :users, :only => [:index,:show,:edit,:update,:destroy]
    admin.resources :purchases, :only => [:index,:show,:update]
    admin.resources :products, :only => [:index]
    admin.resources :stores, :only => [:index,:show,:edit,:update]
    admin.resources :comments, :only => [:index]
    admin.resources :emails, :only => [:index,:show]
    admin.resources :health, :only => [:index]
    admin.resources :suggestions
    admin.resources :themes
    admin.resources :invites, :only => [:index]
    admin.resources :searches, :only => [:index]

    admin.full_purchase ':user_handle/p/:purchase_handle',
      :controller => :purchases,
      :action     => :show

  end

  ##
  # Links for distribution sources.
  ##
  map.connect 'try',
    :controller => :home,
    :action => :show,
    :id => 'twitter'

  map.connect 'adwords',
    :controller => :home,
    :action => :show,
    :id => 'adwords'

  map.connect 'beta',
    :controller => :home,
    :action => :show,
    :id => 'beta'

  map.connect 'tastemaker',
    :controller => :home,
    :action => :show,
    :id => 'tastemaker'

  ##
  # Catch all route for user profiles
  ##
  map.user ':handle',
    :controller => :users,
    :action     => :show

  Jammit::Routes.draw(map)

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
end
