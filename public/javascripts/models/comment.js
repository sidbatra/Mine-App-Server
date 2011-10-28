Denwen.Comment = Backbone.Model.extend({

  urlRoot: '/comments',

  initialize: function() {
  },

  validate: function(attrs) {
    if(attrs.data.length < 1 || attrs.data == this.get('defaultData')) 
      return "No comment entered";
  }

});


