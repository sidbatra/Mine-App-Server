// View js for the Users/Show route
//
Denwen.Views.UsersShow = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    this.userID = this.options.user_id;

    new Denwen.FacebookView();
    this.userProducts = new Denwen.Partials.UserProducts({
                              el      : $('#products'),
                              user_id : this.userID});
    
    this.routing();
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
      }
    });

    new router();
    Backbone.history.start();
  }

});
