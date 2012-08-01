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

  map.tw_auth 'twitter/authenticate',
    :controller => :twitter,
    :action     => :create,
    :filter     => :authenticate

  map.tw_reply 'twitter/reply',
    :controller => :twitter,
    :action     => :create,
    :filter     => :reply

  map.tumblr_auth 'tumblr/authenticate',
    :controller => :tumblr,
    :action     => :create,
    :filter     => :authenticate

  map.tumblr_reply 'tumblr/reply',
    :controller => :tumblr,
    :action     => :create,
    :filter     => :reply

  ##
  # Resoure based routes
  ##
  map.resources :users,
    :only => [:create,:index,:show,:update]

  map.resource :feed,
    :controller => :feed,
    :only => [:show]

  map.short_purchase '/p/:purchase_id',
    :controller => :purchases,
    :action => :show

  map.purchase ':user_handle/p/:purchase_handle',
    :controller => :purchases,
    :action     => :show

  map.edit_purchase ':user_handle/p/:purchase_handle/edit',
    :controller => :purchases,
    :action     => :edit

  map.resources :purchases,
    :only => [:index,:create,:update,:destroy]

  #map.store 's/:handle',
  #  :controller => :stores,
  #  :action     => :show

  map.resources :stores,
    :only => [:index]

  map.resources :comments,
    :only => [:create]

  map.resources :likes,
    :only => [:create]

  #map.resources :followings,
  #  :only => [:create,:show,:destroy]

  map.resources :searches,
    :only => [:create]

  map.resources :products,
    :only => [:index]

  map.resources :suggestions,
    :only => [:index]

  map.resources :facebook,
    :only => [:index,:create]

  map.new_invite 'invite',
    :controller => :invites,
    :action     => :new

  map.resources :invites,
    :only => [:create,:show]

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
    admin.resources :purchases, :only => [:index,:show]
    admin.resources :products, :only => [:index]
    admin.resources :stores, :only => [:index,:show,:edit,:update]
    admin.resources :comments, :only => [:index]
    admin.resources :emails, :only => [:index,:show]
    admin.resources :health, :only => [:index]
    admin.resources :suggestions
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
