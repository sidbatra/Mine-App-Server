// Dialog for sharing the profile page to facebook 
//
Denwen.FacebookShareView = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self  = this;
    this.id   = this.options.id;
    this.url  = this.options.url;

    $(this.id).click(function(){self.openShareDialog();});
  },

  //Constructs url for opening the Facebook share dialog
  //
  constructUrl: function() {
    return "http://www.facebook.com/sharer.php?u=" + this.url;
  },

  //Settings for the popup window 
  //
  popupSettings: function() {
    var w = 626; var h = 436;
    leftPos = (screen.width)  ? (screen.width-w)/2  : 0;
    topPos  = (screen.height) ? (screen.height-h)/2 : 0;
    
   return 'width=' + w + ',height=' + h + ',top=' + topPos + ',left=' + 
          leftPos + ',toolbar=1,status=1,resizable=1,scrollbars=1'
  },

  // Opens Facebook share dialog as a popup to share 
  // the given url
  //
  openShareDialog: function() {
    window.open(
      this.constructUrl(),
      "Facebook",
      this.popupSettings());
  }
});
