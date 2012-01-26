// View js for the Users/Show route
//
Denwen.Views.Users.Show = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    this.user           = new Denwen.Models.User(this.options.userJSON);
    this.isCurrentUser  = helpers.isCurrentUser(this.user.get('id'));
    this.source         = this.options.source;

    this.onTabClass     = 'on';
    this.topStageEl     = '#topstage';
    this.ownsTab        = '#owns_tab';
    this.likesTab       = '#likes_tab';
    this.wantsTab       = '#wants_tab';
    this.followingTab   = '#following_tab';
    this.followedByTab  = '#followed_by_tab';
    this.collectionsTab = '#collections_tab';

    if(this.options.currentUserJSON != 'false')
      this.currentUser  = new Denwen.Models.User(this.options.currentUserJSON);

    // -----
    this.ownedProducts = new Denwen.Partials.Products.Products({
                          el        : $('#centerstage'),
                          owner_id  : this.user.get('id'),
                          filter    : 'user',
                          type      : 'user',
                          fragment  : 'owns'});

    // -----
    this.likedProducts = new Denwen.Partials.Products.Products({
                            el        : $('#centerstage'),
                            owner_id  : this.user.get('id'),
                            filter    : 'liked',
                            type      : 'user',
                            fragment  : 'likes'});

    // -----
    this.wantedProducts = new Denwen.Partials.Products.Products({
                            el        : $('#centerstage'),
                            owner_id  : this.user.get('id'),
                            filter    : 'wanted',
                            type      : 'user',
                            fragment  : 'wants'});

    // -----
    this.followingUsers  = new Denwen.Partials.Users.List({
                                el      : $('#centerstage'),
                                userID  : this.user.get('id'),
                                filter  : 'ifollowers',
                                header  : 'Following',
                                src     : 'following_list'});

    // -----
    this.followedByUsers  = new Denwen.Partials.Users.List({
                                  el      : $('#centerstage'),
                                  userID  : this.user.get('id'),
                                  filter  : 'followers',
                                  header  : 'Followed By',
                                  src     : 'followed_by_list'});

    // -----
    this.collections      = new Denwen.Partials.Collections.List({
                                  el      : $('#centerstage'),
                                  ownerID : this.user.get('id'),
                                  filter  : 'user',
                                  source  : 'user_collections'});

    // -----
    //this.onCollection     = new Denwen.Partials.Collections.OnToday({
    //                              el      : $('#topstage'),
    //                              userID  : this.user.get('id')});

    // -----
    new Denwen.Partials.Users.PreviewBox({
                          el      : $('#ifollowers_with_msg'),
                          user    : this.user,
                          filter  : 'ifollowers_preview',
                          header  : 'Following',
                          count   : this.user.get('inverse_followings_count'),
                          hash    : 'following'});
    
    // -----
    new Denwen.Partials.Users.PreviewBox({
                          el      : $('#followers_with_msg'),
                          user    : this.user,
                          filter  : 'followers_preview',
                          header  : 'Followed by',
                          count   : this.user.get('followings_count'),
                          hash    : 'followed_by'});

    // -----
    new Denwen.Partials.Users.Stores({
                          el    : '#user_stores_box',
                          user  : this.user});

    // -----
    //window.setTimeout(function() {
    //          new Denwen.Partials.Users.Stars({
    //                      el  : '#star_users_box'});
    //                      },500);

    //// -----
    //window.setTimeout(function() {
    //          new Denwen.Partials.Stores.Top({
    //                      el  : '#top_stores_box'});
    //                      },500);

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

  // Fetch owned products and update the topstage
  // 
  fetchOwnedProducts: function(category) {
    this.ownedProducts.fetch(category);

    //if(category == 'all' || category == undefined)
    //  this.onCollection.fetch();
  },

  // Load facebook code via partials
  //
  loadFacebookPlugs: function() {
    new Denwen.Partials.Facebook.Base();
  },

  // Clear the top stage area
  //
  clearTopStage: function() {
    $(this.topStageEl).html('');
  },

  // Reset all tabs to off state
  //
  switchTabsOff: function() {
    $(this.ownsTab).removeClass(this.onTabClass);
    $(this.likesTab).removeClass(this.onTabClass);
    $(this.wantsTab).removeClass(this.onTabClass);
    $(this.followingTab).removeClass(this.onTabClass);
    $(this.followedByTab).removeClass(this.onTabClass);
    $(this.collectionsTab).removeClass(this.onTabClass);
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

      // Display owns,likes,wants with categoty filters
      //
      doubleFilter: function(type,category) {
        self.switchTabsOff();

        switch(type) {
        case Denwen.UserShowHash.Owns:
          self.fetchOwnedProducts(category);
          $(self.ownsTab).addClass(self.onTabClass);
          break;

        case Denwen.UserShowHash.Likes:
          self.likedProducts.fetch(category);
          $(self.likesTab).addClass(self.onTabClass);
          self.clearTopStage();
          break;

        case Denwen.UserShowHash.Wants:
          self.wantedProducts.fetch(category);
          $(self.wantsTab).addClass(self.onTabClass);
          self.clearTopStage();
          break;

        default:
          self.fetchOwnedProducts();
          $(self.ownsTab).addClass(self.onTabClass);
        }

        analytics.userProductsView(type,category,self.user.get('id'));
      },

      // Display ifollowers, followers and handle empty fragments
      //
      singleFilter: function(type) {
        self.switchTabsOff();

        switch(type) {
        case Denwen.UserShowHash.Following:
          self.followingUsers.fetch();
          $(self.followingTab).addClass(self.onTabClass);
          self.clearTopStage();
          analytics.userIFollowersView(self.user.get('id'));
          break;

        case Denwen.UserShowHash.FollowedBy:
          self.followedByUsers.fetch();
          $(self.followedByTab).addClass(self.onTabClass);
          self.clearTopStage();
          analytics.userFollowersView(self.user.get('id'));
          break;

        case Denwen.UserShowHash.Collections:
          self.collections.fetch();
          $(self.collectionsTab).addClass(self.onTabClass);
          self.clearTopStage();
          analytics.userCollectionsView(self.user.get('id'));
          break;

        default:
          self.fetchOwnedProducts();
          $(self.ownsTab).addClass(self.onTabClass);
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

      analytics.identifyUser(
        this.currentUser.get('email'),
        this.currentUser.get('age'));

      analytics.trackVersion(helpers.version);
    }
  }
  
});
