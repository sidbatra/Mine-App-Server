// View js for the Users/Show route
//
Denwen.Views.Users.Show = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    this.user           = new Denwen.Models.User(this.options.userJSON);
    this.isCurrentUser  = helpers.isCurrentUser(this.user.get('id'));
    this.source         = this.options.source;
    this.currentTab     = undefined;

    this.onTabClass     = 'on';
    this.loadTabClass   = 'load';
    this.ownsTab        = '#owns_tab';
    this.wantsTab       = '#wants_tab';
    this.followingTab   = '#following_tab';
    this.followedByTab  = '#followed_by_tab';
    this.collectionsTab = '#collections_tab';

    if(this.options.currentUserJSON != 'false')
      this.currentUser  = new Denwen.Models.User(this.options.currentUserJSON);

    // -----
    this.ownedProducts = new Denwen.Partials.Products.Products({
                          el          : $('#centerstage'),
                          owner_id    : this.user.get('id'),
                          owner_name  : this.user.get('first_name'),
                          filter      : 'user',
                          type        : 'user',
                          fragment    : 'owns'});

    this.ownedProducts.bind(
      Denwen.Callback.ProductsLoaded,
      this.productsLoaded,
      this);

    // -----
    this.wantedProducts = new Denwen.Partials.Products.Products({
                            el        : $('#centerstage'),
                            owner_id  : this.user.get('id'),
                          owner_name  : this.user.get('first_name'),
                            filter    : 'wanted',
                            type      : 'user',
                            fragment  : 'wants'});

    this.wantedProducts.bind(
      Denwen.Callback.ProductsLoaded,
      this.productsLoaded,
      this);

    // -----
    this.followingUsers  = new Denwen.Partials.Users.List({
                                el      : $('#centerstage'),
                                userID  : this.user.get('id'),
                                filter  : 'ifollowers',
                                header  : 'Following',
                                src     : 'following_list'});

    this.followingUsers.bind(
      Denwen.Callback.UsersListLoaded,
      this.usersLoaded,
      this);

    // -----
    this.followedByUsers  = new Denwen.Partials.Users.List({
                                  el      : $('#centerstage'),
                                  userID  : this.user.get('id'),
                                  filter  : 'followers',
                                  header  : 'Followed By',
                                  src     : 'followed_by_list'});

    this.followedByUsers.bind(
      Denwen.Callback.UsersListLoaded,
      this.usersLoaded,
      this);

    // -----
    this.collections      = new Denwen.Partials.Collections.List({
                                  el      : $('#centerstage'),
                                  ownerID : this.user.get('id'),
                                  filter  : 'user',
                            productsLeft  : CONFIG['products_threshold'] - 
                                              this.user.get('products_count'),
                                  source  : 'user_collections'});

    this.collections.bind(
      Denwen.Callback.CollectionsListLoaded,
      this.collectionsLoaded,
      this);

    // -----
    new Denwen.Partials.Users.PreviewBox({
                          el      : $('#ifollowers_with_msg'),
                          user    : this.user,
                          filter  : 'ifollowers_preview',
                          header  : 'Influenced by',
                          count   : this.user.get('inverse_followings_count'),
                          hash    : 'following'});
    
    // -----
    //new Denwen.Partials.Users.PreviewBox({
    //                      el      : $('#followers_with_msg'),
    //                      user    : this.user,
    //                      filter  : 'followers_preview',
    //                      header  : 'Followed by',
    //                      count   : this.user.get('followings_count'),
    //                      hash    : 'followed_by'});

    // -----
    new Denwen.Partials.Users.Stores({
                          el    : '#user_stores_box',
                          user  : this.user});

    // -----
    if(!this.isCurrentUser && helpers.isLoggedIn())
      new Denwen.Partials.Users.Following({
                            el  : $('#following_box_' + this.user.get('id')),
                            user_id : this.user.get('id')});

    // -----
    if(this.isCurrentUser)
      new Denwen.Partials.Users.Byline({
                    model: this.user, 
                    el:$('#profile_bio')});

    // ----
    this.routing();

    // -----
    this.loadFacebookPlugs();

    // -----
    this.setAnalytics();
  },

  // Load facebook code via partials
  //
  loadFacebookPlugs: function() {
    new Denwen.Partials.Facebook.Base();
  },

  // Reset all tabs to off state
  //
  switchTabsOff: function() {
    $(this.ownsTab).removeClass(this.onTabClass);
    $(this.wantsTab).removeClass(this.onTabClass);
    $(this.followingTab).removeClass(this.onTabClass);
    $(this.followedByTab).removeClass(this.onTabClass);
    $(this.collectionsTab).removeClass(this.onTabClass);
    $(this.ownsTab).removeClass(this.loadTabClass);
    $(this.wantsTab).removeClass(this.loadTabClass);
    $(this.followingTab).removeClass(this.loadTabClass);
    $(this.followedByTab).removeClass(this.loadTabClass);
    $(this.collectionsTab).removeClass(this.loadTabClass);
  },

  // Switch on the given tab element
  //
  switchTabOn: function(tab) {
    this.currentTab = tab;
    $(tab).addClass(this.loadTabClass);
    $(tab).addClass(this.onTabClass);
  },

  // Remove loading state from the current tab
  //
  switchCurrentTabLoadOff: function() {
    $(this.currentTab).removeClass(this.loadTabClass);
  },

  // Load tab that displays the user's collections
  //
  loadCollectionsTab: function() {
    this.collections.fetch();
    this.switchTabOn(this.collectionsTab);

    if(this.user.get('collections_count'))
      analytics.userCollectionsView(this.user.get('id'));
    else if(this.user.get('products_count') < CONFIG['products_threshold'])
      analytics.collectionOnboardingPreviewed();
    else
      analytics.collectionOnboardingViewed('faded_timeline');
  },

  // Load tab that displays the user's owns
  //
  loadOwnsTab: function(category) {
    this.ownedProducts.fetch(category);
    this.switchTabOn(this.ownsTab);
    analytics.userProductsView('owns',category,this.user.get('id'));
  },

  // Load the default tab. Used when a hash fragment
  // isn't explicitly set
  //
  loadDefaultTab: function() {
    if((this.isCurrentUser && this.user.get('collections_count'))){
      this.loadCollectionsTab();
    }
    else {
      this.loadOwnsTab();
    }
  },

  // Use Backbone router for reacting to changes in URL
  // fragments
  //
  routing: function() {
    var self = this;

    var router = Backbone.Router.extend({

      // Listen to routes
      //
      routes: {
        ":type/:category" : "doubleFilter",
        ":type"           : "singleFilter"
      },

      // Display owns,wants with categoty filters
      //
      doubleFilter: function(type,category) {
        self.switchTabsOff();

        switch(type) {
        case Denwen.UserShowHash.Owns:
          self.loadOwnsTab(category);
          break;

        case Denwen.UserShowHash.Wants:
          self.wantedProducts.fetch(category);
          self.switchTabOn(self.wantsTab);
          analytics.userProductsView(type,category,self.user.get('id'));
          break;

        default:
          self.loadDefaultTab();
        }

      },

      // Display ifollowers, followers and handle empty fragments
      //
      singleFilter: function(type) {
        self.switchTabsOff();

        switch(type) {
        case Denwen.UserShowHash.Following:
          self.followingUsers.fetch();
          self.switchTabOn(self.followingTab);
          analytics.userIFollowersView(self.user.get('id'));
          break;

        case Denwen.UserShowHash.FollowedBy:
          self.followedByUsers.fetch();
          self.switchTabOn(self.followedByTab);
          analytics.userFollowersView(self.user.get('id'));
          break;

        case Denwen.UserShowHash.Collections:
          self.loadCollectionsTab();
          break;

        default:
          self.loadDefaultTab();
        }
      }
    });

    new router();
    Backbone.history.start();
  },

  // Fire various tracking events 
  //
  setAnalytics: function() {

    analytics.userLandsOn(this.user.uniqueKey());

    analytics.userProfileView(
      this.source,
      this.user.get('id'));

    if(this.source.slice(0,6) == 'email_')
      analytics.emailClicked(this.source.slice(6,this.source.length));

    if(this.isCurrentUser) {

      if(this.source == 'product_create')
        analytics.productCreated();
      else if(this.source == 'login')
        analytics.userLogin();
      else if(this.source == 'product_deleted')
        analytics.productDeleted();
      else if(this.source == 'collection_create')
        analytics.collectionCreated();
      else if(this.source == 'collection_cancel')
        analytics.collectionCancelled();
      else if(this.source == 'collection_deleted')
        analytics.collectionDeleted();

      analytics.identifyUser(
        this.currentUser.get('email'),
        this.currentUser.get('age'));

      analytics.trackVersion(helpers.version);
    }
  },

  // Callback when owns or wants are loaded
  //
  productsLoaded: function() {
    this.switchCurrentTabLoadOff();
  },

  // Callback when followers or ifollowers are loaded
  //
  usersLoaded: function() {
    this.switchCurrentTabLoadOff();
  },

  // Callback when collections are loaded
  //
  collectionsLoaded: function() {
    this.switchCurrentTabLoadOff();
  }
  
});
