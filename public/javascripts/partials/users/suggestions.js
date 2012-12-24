Denwen.Partials.Users.Suggestions = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    var self = this;
    this.suggestionsEl = '#user_suggestions';
    this.perPage = this.options.perPage;

    this.users = new Denwen.Collections.Users();
    this.users.fetch({
      data    : {aspect: 'suggestions',per_page:this.perPage},
      success : function(){self.fetched()},
      error   : function(){}});
  },

  // Fired when the suggested users are fetched
  //
  fetched: function() {
    var self = this;

    this.users.each(function(user){
      new Denwen.Partials.Users.Suggestion({
            el: $(self.suggestionsEl),
            model: user});
    });

    if(this.users.length)
      this.el.show();
  }
});
