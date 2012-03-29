ActionController::Routing::Routes.draw do |map|

  map.root :controller  => :home,
            :action     => :show

  map.welcome_create '/welcome/create',
                :controller => :products,
                :action     => :new

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

  map.privacy   'privacy',
                :controller => :static,
                :action     => :show,
                :filter     => :privacy

  map.terms     'terms',
                :controller => :static,
                :action     => :show,
                :filter     => :terms

  map.terms     'copyright',
                :controller => :static,
                :action     => :show,
                :filter     => :copyright

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
  map.logged_exceptions 'admin/logged_exceptions/:action/:id', 
              :controller => 'logged_exceptions'

  map.resources :users,
                :only => [:create,:show,:update]

  map.resources :products,
                :only => [:create,:update,:destroy]

  map.resources :stores,
                :only => [:index]

  map.resources :followings,
                :only => [:create,:show,:destroy]

  map.resources :searches,
                :only => [:create]

  map.resources :search,
                :only => [:index],
                :controller => :search

  map.resources :invites,
                :only => [:create]

  map.resources :suggestions,
                :only => [:index]

  map.resources :facebook,
                :only => [:index,:create]

  map.new_invite '/invite',
                  :controller => :invites,
                  :action => :new

  map.resources :contacts,
                :only => [:index]

  map.resources :welcome,
                :only       => [:show,:create],
                :controller => :welcome

  map.resources :settings,
                :only => [:index,:update,:show]

  # Admin routes
  map.resources :admin_users, 
                :as         => 'admin/users', 
                :controller => 'admin/users',
                :only       => [:index,:show,:destroy]
  
  map.resources :admin_stores, 
                :as         => 'admin/stores', 
                :controller => 'admin/stores',
                :only       => [:index,:edit,:update]

  map.resources :admin_emails,
                :as         => 'admin/emails',
                :controller => 'admin/emails',
                :only       => [:index,:show]

  map.resources :admin_health,
                :as         => 'admin/health',
                :controller => 'admin/health',
                :only       => :index

  map.resources :admin_suggestions,
                :as         => 'admin/suggestions',
                :controller => 'admin/suggestions'

  map.admin '/admin',
                :controller => 'admin/help',
                :action     => :show

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
