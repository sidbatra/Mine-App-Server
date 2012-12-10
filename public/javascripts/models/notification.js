Denwen.Models.Notification = Backbone.Model.extend({
  
  urlRoot: '/notifications',

  initialize: function() {
    this.associate('user',Denwen.Models.User);
    this.associate('purchase',Denwen.Models.Purchase);
  },

  path: function(src) {
    var path = "";

    switch(this.get('identifier')) {
    case Denwen.NotificationIdentifier.Following:
      path = this.get('user').path(src);
      break;
    case Denwen.NotificationIdentifier.Like:
    case Denwen.NotificationIdentifier.Comment:
      path = this.get('purchase').path(src);
      break;
    case Denwen.NotificationIdentifier.UnapprovedPurchases:
      path = '/purchases/unapproved?src=' + src;
      break;
    default:
      break;
    }

    return path;
  }

});


