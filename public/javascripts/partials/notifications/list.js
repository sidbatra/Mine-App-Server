Denwen.Partials.Notifications.List = Backbone.View.extend({
  
  initialize: function() {
    var self = this;

    this.notificationsEl = "#notifications";

    this.notifications = new Denwen.Collections.Notifications();
    this.notifications.fetch({
          data      : {},
          success   : function(collection){self.notificationsLoaded();},
          error     : function(collection,errors){}});
  },

  notificationsLoaded: function() {
    var self = this;

    this.notifications.each(function(notification){
      $(self.notificationsEl).append(Denwen.JST['notifications/notification']({
        notification:notification}));
    });

    if(this.notifications.length)
      this.el.show();
  }
});

