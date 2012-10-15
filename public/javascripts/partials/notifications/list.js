Denwen.Partials.Notifications.List = Backbone.View.extend({
  
  initialize: function() {
    var self = this;

    this.notificationsEl = "#notifications";
    this.markedAsRead = false;

    this.notifications = new Denwen.Collections.Notifications();
    this.notifications.fetch({
          data      : {},
          success   : function(collection){self.notificationsLoaded();},
          error     : function(collection,errors){}});

    this.el.click(function(){self.notificationBoxClicked();return true;});
  },

  markAsRead: function() {
    if(!this.notifications.length || this.markedAsRead)
      return;

    this.markedAsRead = true;

    var unreadIDs = [];

    this.notifications.each(function(notification){
      if(notification.get('unread'))
        unreadIDs.push(notification.get('id'));
    });

    var notification = new Denwen.Models.Notification({
                            id:0,
                            unread_ids:unreadIDs.join()});

    if(unreadIDs.length)
      notification.save();
  },

  notificationBoxClicked: function() {
    this.el.find(".dropdown-toggle").addClass('zero').html('0');
    this.markAsRead();
  },

  notificationsLoaded: function() {
    var self = this;

    this.notifications.each(function(notification){
      $(self.notificationsEl).append(Denwen.JST['notifications/notification']({
        notification:notification}));
    });

    if(this.notifications.length)
      this.el.show();
    else
      this.el.hide();

    if(Denwen.Device.get("is_phone"))
      this.markAsRead();
  }
});

