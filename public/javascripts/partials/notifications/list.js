Denwen.Partials.Notifications.List = Backbone.View.extend({
  
  initialize: function() {
    var self = this;

    this.notifications = new Denwen.Collections.Notifications();
    this.notifications.fetch({
          data      : {},
          success   : function(collection){self.notificationsLoaded();},
          error     : function(collection,errors){}});
  },

  notificationsLoaded: function() {
    this.notifications.each(function(notification){
      this.el.append(Denwen.JST['notifications/notification']({
        notification:notification}));
    });
  }
});

