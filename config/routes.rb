ActionController::Routing::Routes.draw do |map|

  map.root :controller  => :home,
    :action => :show

  map.home 'home/:id', 
    :controller => :home, 
    :action => :show

  map.login 'facebook/authenticate',
    :controller => :session,
    :action     => :create

  map.logout 'logout',
    :controller => :session,
    :action     => :destroy

  map.fb_auth 'facebook/authenticate',
    :controller => :session,
    :action     => :create

  map.fb_reply 'facebook/reply',
    :controller => :users,
    :action     => :create

  map.canvas '/canvas',
    :controller => :canvas,
    :action     => :show


  ##
  # Resoure based routes
  ##
  map.resources :users,
    :only => [:create,:show,:update]

  map.product ':user_handle/p/:product_handle',
    :controller => :products,
    :action     => :show

  map.edit_product ':user_handle/p/:product_handle/edit',
    :controller => :products,
    :action     => :edit

  map.resources :products,
    :only => [:create,:update,:destroy]

  map.store 's/:handle',
    :controller => :stores,
    :action     => :show

  map.resources :stores,
    :only => [:index]

  #map.resources :followings,
  #  :only => [:create,:show,:destroy]

  map.resources :searches,
    :only => [:create]

  map.resources :search,
    :only       => [:index],
    :controller => :search

  map.resources :suggestions,
    :only => [:index]

  map.resources :facebook,
    :only => [:index,:create]

  map.new_invite 'invite',
    :controller => :invites,
    :action     => :new

  map.resources :invites,
    :only => [:create]

  map.resources :contacts,
    :only => [:index]

  map.resources :welcome,
    :only       => [:show,:create],
    :controller => :welcome

  map.resources :settings,
    :only => [:index,:update,:show]


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


  ##
  # Admin namespace routes routes
  ##

  map.logged_exceptions 'admin/logged_exceptions/:action/:id', 
    :controller => 'logged_exceptions'

  map.admin 'admin',
    :controller => 'admin/help',
    :action     => :show

  map.namespace(:admin) do |admin|
    admin.resources :users, :only => [:index,:show,:destroy]
    admin.resources :stores, :only => [:index,:edit,:update]
    admin.resources :emails, :only => [:index,:show]
    admin.resources :health, :only => [:index]
    admin.resources :suggestions
  end


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
