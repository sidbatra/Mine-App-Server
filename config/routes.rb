ActionController::Routing::Routes.draw do |map|

  map.root :controller  => :home,
           :action      => :show

  map.login   '/',
              :controller => :home,
              :action     => :show

  map.logout  '/logout',
              :controller => :session,
              :action     => :destroy

  map.fb_auth 'facebook/authenticate',
               :controller  => :session,
               :action      => :create

  map.fb_reply 'facebook/reply',
                :controller => :users,
                :action     => :create

  # Exception manager
  map.connect 'admin/logged_exceptions/:action/:id', 
              :controller => 'logged_exceptions'

  map.resources :users,
                :only => [:create]

  map.resources :products,
                :only => [:new,:create,:show]

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
end
