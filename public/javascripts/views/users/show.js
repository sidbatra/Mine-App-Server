// View js for the Users/Show route
//
Denwen.Views.Users.Show = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    this.user           = new Denwen.Models.User(this.options.userJSON);
    this.isCurrentUser  = helpers.isCurrentUser(this.user.get('id'));
    this.source         = this.options.source;

    if(this.options.currentUserJSON != 'false')
      this.currentUser  = new Denwen.Models.User(this.options.currentUserJSON);

    // -----
    this.userProducts   = new Denwen.Partials.Users.Products({
                                el      : $('#products'),
                                user_id : this.user.get('id')});
    
    // -----
    this.routing();

    // -----
    new Denwen.Partials.Users.IFollowers({
                          el    : $('#ifollowers_with_msg'),
                          user  : this.user,
                          delay : this.isCurrentUser && 
                                  this.user.get('followings_count') <= 0 
                                  && this.source == 'login'});
    // -----
    new Denwen.Partials.Users.Stars();

    // -----
    if(this.isCurrentUser)
      new Denwen.Partials.Users.Byline({
                    model: this.user, 
                    el:$('#profile_bio')});


    // -----
    this.loadFacebookPlugs();

    // -----
    this.setAnalytics();
  },

  // Load facebook code via partials
  //
  loadFacebookPlugs: function() {
    new Denwen.Partials.Facebook.Base();

    if(this.isCurrentUser)
      new Denwen.Partials.Facebook.Invite({id:'#action_link'});
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
      else if(this.source == 'product_deleted')
        analytics.productDeleted();

      analytics.identifyUser(
        this.currentUser.get('email'),
        this.currentUser.get('age'));
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
        ":category" : "filter"
      },

      // Called when a filter route is fired
      //
      filter: function(category) {
        self.userProducts.filter(category);

        if(category != undefined && category.length) {
          analytics.userProfileFiltered(
                      category,
                      self.isCurrentUser,
                      self.user.get('id'));
        }
      }
    });

    new router();
    Backbone.history.start();
  }

});
