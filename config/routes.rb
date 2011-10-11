ActionController::Routing::Routes.draw do |map|

  map.root :controller  => :home,
            :action     => :show

  map.home  '/:id',
            :controller => :home,
            :action     => :show
  #map.root :controller  => :products,
  #         :action      => :show,
  #         :id          => 1,
  #         :name        => "Diamondback-Insight-Bike"

  map.login   'facebook/authenticate',
              :controller => :session,
              :action     => :create

  map.logout  '/logout',
              :controller => :session,
              :action     => :destroy

  map.fb_auth 'facebook/authenticate',
               :controller  => :session,
               :action      => :create

  map.fb_reply 'facebook/reply',
                :controller => :users,
                :action     => :create

  map.product 'products/:id/:name',
                :controller => :products,
                :action     => :show

  # Exception manager
  map.connect 'admin/logged_exceptions/:action/:id', 
              :controller => 'logged_exceptions'

  map.resources :users,
                :only => [:create]

  map.resources :products,
                :only => [:new,:create]

  map.resource  :share,
                :controller => 'share',
                :only       => [:create]
      

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
end
