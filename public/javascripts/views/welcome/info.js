Denwen.Views.Welcome.Info = Backbone.View.extend({

  initialize: function() {
    var self = this;

    this.emailEl = '#email';
    this.formEl = '#edit_user';

    $(this.formEl).submit(function(){return self.post();});

    this.setAnalytics();
  },

  post: function() {
    var valid = true;

    if(!$(this.emailEl).val().length) {
      $(this.emailEl).addClass('error');
      valid = false;
    }

    if(valid) 
      $(this.formEl).addClass('load');

    return valid;
  },

  setAnalytics: function() {
    Denwen.Track.action("Welcome Info");
  }

});
