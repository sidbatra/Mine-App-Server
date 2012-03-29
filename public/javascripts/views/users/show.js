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

    this.onTabClass     = 'active';
    this.loadTabClass   = 'load';
    this.ownsTab        = '#owns_tab';
    this.wantsTab       = '#wants_tab';

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

    this.ownedProducts.bind(
      Denwen.Callback.ProductsRendered,
      this.ownsRendered,
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
    $(this.ownsTab).removeClass(this.loadTabClass);
    $(this.wantsTab).removeClass(this.loadTabClass);
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

  // Load tab that displays the user's owns
  //
  loadOwnsTab: function() {
    this.ownedProducts.fetch();
    this.switchTabOn(this.ownsTab);

    analytics.userProductsView(
      Denwen.UserShowHash.Owns,
      this.user.get('id'));
  },

  // Load tab that displays the user's wants
  //
  loadWantsTab: function() {
    this.wantedProducts.fetch();
    this.switchTabOn(this.wantsTab);

    analytics.userProductsView(
      Denwen.UserShowHash.Wants,
      this.user.get('id'));
  },

  // Load the default tab. Used when a hash fragment
  // isn't explicitly set
  //
  loadDefaultTab: function() {
    this.loadOwnsTab();
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
        ":type" : "filter"
      },

      // 
      //
      filter: function(type) {
        self.switchTabsOff();

        switch(type) {
        case Denwen.UserShowHash.Owns:
          self.loadOwnsTab();
          break;

        case Denwen.UserShowHash.Wants:
          self.loadWantsTab();
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

    if(this.isCurrentUser) {

      if(this.source == 'product_create')
        analytics.productCreated();
      else if(this.source == 'login')
        analytics.userLogin();
      else if(this.source == 'user_create')
        analytics.userCreated();
      else if(this.source == 'product_deleted')
        analytics.productDeleted();

      analytics.identifyUser(
        this.currentUser.get('email'),
        this.currentUser.get('age'),
        this.currentUser.get('gender'));

      analytics.trackVersion(helpers.version.slice(0,-2));
    }

    analytics.checkForEmailClickedEvent(this.source);
  },

  // Callback when owns or wants are loaded
  //
  productsLoaded: function() {
    this.switchCurrentTabLoadOff();
  },

  // Callback when owns are rendered
  //
  ownsRendered: function() {
    if(this.isCurrentUser) 
      new Denwen.Partials.Suggestions.Product({el :$('#suggestions')});
  }
  
});
