Denwen.Models.Notification = Backbone.Model.extend({
  
  urlRoot: '/notifications',

  initialize: function() {
    this.associate('user',Denwen.Models.User);
    this.associate('purchase',Denwen.Models.Purchase);
  },

  path: function(src) {
    var path = "";

    if(this.get('resource_type') == 'User')
      path = this.get('user').path(src);
    else if(this.get('resource_type') == 'Purchase')
      path = this.get('purchase').path(src);

    return path;
  }

});


