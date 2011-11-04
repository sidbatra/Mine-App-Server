// Collection of User models holding the user's iFollowers 
//
Denwen.Users = Backbone.Collection.extend({

  //Url 
  //
  url:    '/users',

  // Constructor logic
  //
  initialize: function() {

  },

  /* Parse out the results from the response before passing
  // it to the collection
  //
  parse: function(data) {
    var results = [];
    var images  = data['SearchResponse']['Image']['Results'];

    return results;
  }*/

});
