Denwen.User = Backbone.Model.extend({
  
  urlRoot: '/users',

  initialize: function() {
  },

  validate: function(attrs) {
    if(attrs.byline.length < 1)
      return "Byline can't be empty";
  }

});


