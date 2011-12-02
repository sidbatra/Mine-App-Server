ActionController::Routing::Routes.draw do |map|

  map.root :controller  => :home,
            :action     => :show

  map.welcome   '/welcome',
                :controller => :welcome,
                :action     => :show

  map.home      '/home/:id',
                :controller => :home,
                :action     => :show

  map.login     'facebook/authenticate',
                :controller => :session,
                :action     => :create

  map.logout    '/logout',
                :controller => :session,
                :action     => :destroy

  map.fb_auth   'facebook/authenticate',
                :controller => :session,
                :action     => :create

  map.fb_reply  'facebook/reply',
                :controller => :users,
                :action     => :create


  # Deprecate in next version
  map.product_d 'products/:id/:name',
                :controller => :products,
                :action     => :show

  map.product ':user_handle/p/:product_handle',
                :controller => :products,
                :action     => :show

  map.edit_product ':user_handle/p/:product_handle/edit',
                    :controller => :products,
                    :action     => :edit

  map.store   's/:handle',
                :controller => :stores,
                :action     => :show

  map.connect 'admin/stores/unapproved',
              :controller   => 'admin/stores',
              :action       => :index,
              :filter       => :unapproved

  map.connect 'admin/stores/popular',
              :controller   => 'admin/stores',
              :action       => :index,
              :filter       => :popular

  # Exception manager
  map.connect 'admin/logged_exceptions/:action/:id', 
              :controller => 'logged_exceptions'

  map.resources :users,
                :only => [:create,:show,:update,:index]

  map.resources :products,
                :only => [:new,:create,:index,:update,:destroy]

  map.resources :stores,
                :only => [:index]

  map.resources :comments,
                :only => [:create,:index]

  map.resources :actions,
                :only => [:create,:index]

  map.resources :followings,
                :only => [:create,:show,:destroy]

  map.resources :searches,
                :only => [:create]

  map.resources :invites,
                :only => [:create,:new]

  map.resources :contacts,
                :only => [:index]

  map.resource  :share,
                :controller => 'share',
                :only       => [:create]

  # Admin routes
  map.resources :admin_users, 
                :as         => 'admin/users', 
                :controller => 'admin/users',
                :only       => [:index,:show]
  
  map.resources :admin_stores, 
                :as         => 'admin/stores', 
                :controller => 'admin/stores',
                :only       => [:index,:update,:show]

  map.canvas    '/canvas',
                :controller => :canvas,
                :action     => :show
  
  Jammit::Routes.draw(map)
        

  map.user  '/:handle',
            :controller => :users,
            :action     => :show

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
end
