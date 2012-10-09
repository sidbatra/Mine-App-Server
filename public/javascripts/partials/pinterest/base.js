Denwen.Partials.Pinterest.Base = Backbone.View.extend({

  initialize: function() {
    var self  = this;
    $(document).ready(function(){self.loadJavascriptSDK();});  
  },

  loadJavascriptSDK: function() {
    $.ajax({ 
        url: '//assets.pinterest.com/js/pinit.js', 
        dataType: 'script', 
        cache:true});
  }
});
