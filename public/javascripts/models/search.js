Denwen.Search = Backbone.Model.extend({

  urlRoot: '/searches',

  initialize: function() {
  },

  validate: function(attrs) {
    if(attrs.query.length < 1)
      return "No query entered";
  }

});
