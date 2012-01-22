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
    this.ownsTab        = '#owns_tab';
    this.likesTab       = '#likes_tab';
    this.wantsTab       = '#wants_tab';
    this.followingTab   = '#following_tab';
    this.followedByTab  = '#followed_by_tab';

    if(this.options.currentUserJSON != 'false')
      this.currentUser  = new Denwen.Models.User(this.options.currentUserJSON);

    // -----
    this.ownedProducts = new Denwen.Partials.Products.Products({
                          el        : $('#products'),
                          owner_id  : this.user.get('id'),
                          filter    : 'user',
                          type      : 'user',
                          fragment  : 'owns'});

    // -----
    this.likedProducts = new Denwen.Partials.Products.Products({
                            el        : $('#products'),
                            owner_id  : this.user.get('id'),
                            filter    : 'liked',
                            type      : 'user',
                            fragment  : 'likes'});

    // -----
    this.wantedProducts = new Denwen.Partials.Products.Products({
                            el        : $('#products'),
                            owner_id  : this.user.get('id'),
                            filter    : 'wanted',
                            type      : 'user',
                            fragment  : 'wants'});

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

  // Load facebook code via partials
  //
  loadFacebookPlugs: function() {
    new Denwen.Partials.Facebook.Base();
  },

  // Reset all tabs to off state
  //
  switchTabsOff: function() {
    $(this.ownsTab).removeClass(this.onTabClass);
    $(this.likesTab).removeClass(this.onTabClass);
    $(this.wantsTab).removeClass(this.onTabClass);
    $(this.followingTab).removeClass(this.onTabClass);
    $(this.followedByTab).removeClass(this.onTabClass);
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
          self.ownedProducts.fetch(category);
          $(self.ownsTab).addClass(self.onTabClass);
          break;
        case Denwen.UserShowHash.Likes:
          self.likedProducts.fetch(category);
          $(self.likesTab).addClass(self.onTabClass);
          break;
        case Denwen.UserShowHash.Wants:
          self.wantedProducts.fetch(category);
          $(self.wantsTab).addClass(self.onTabClass);
          break;
        default:
          self.ownedProducts.fetch();
          $(self.ownsTab).addClass(self.onTabClass);
        }
      },

      // Display ifollowers, followers and handle empty fragments
      //
      singleFilter: function(type) {
        self.switchTabsOff();

        switch(type) {
        case Denwen.UserShowHash.Following:
          console.log('followings');
          $(self.followingTab).addClass(self.onTabClass);
          break;
        case Denwen.UserShowHash.FollowedBy:
          console.log('followed by');
          $(self.followedByTab).addClass(self.onTabClass);
          break;
        default:
          self.ownedProducts.fetch();
          $(self.ownsTab).addClass(self.onTabClass);
        }

        //if(category != undefined && category.length && category != '_=_') {
        //  analytics.userProfileFiltered(
        //              category,
        //              self.isCurrentUser,
        //              self.user.get('id'));
        //}
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
    }
  }
  
});
