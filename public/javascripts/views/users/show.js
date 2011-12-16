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
    this.shelves = new Denwen.Partials.Products.Shelves({
                        el        : $('#shelves'),
                        filter    : 'user',
                        onFilter  : 'collection',
                        ownerID   : this.user.get('id'),
                        isActive  : helpers.isCurrentUser(this.user.get('id'))});
    
    // -----
    new Denwen.Partials.Users.IFollowers({
                          el    : $('#ifollowers_with_msg'),
                          user  : this.user,
                          delay : this.isCurrentUser && 
                                  this.user.get('inverse_followings_count') <= 0
                                  && this.source == 'login'});
    // -----
    new Denwen.Partials.Users.Stores({
                          el    : '#user_stores_box',
                          user  : this.user});

    // -----
    new Denwen.Partials.Users.Stars({
                          el  : '#star_users_box'});

    // -----
    new Denwen.Partials.Stores.Top({
                          el  : '#top_stores_box'});

    if(!this.isCurrentUser && helpers.isLoggedIn())
      new Denwen.Partials.Users.Following({
                            el  : $('#following_box'),
                            user_id : this.user.get('id')});
                          

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

      analytics.identifyUser(
        this.currentUser.get('email'),
        this.currentUser.get('age'));
    }
  }
  
});
