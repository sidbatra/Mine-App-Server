// Edit settings
//
Denwen.Views.Settings.Index = Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self = this;

    this.source = this.options.source;

    // Attach listeners on to setting checkboex
    //
    _.each(this.el.find('input'),function(input){
      if(input.type == 'checkbox')
        $('#' + input.id).change(function(){self.settingToggled(this)});
    });

    // -----
    this.displayFlashMessage();

    // -----
    this.setAnalytics();
  },

  // Fired when a setting check box is toggled
  //
  settingToggled: function(checkBox) {
    var name = checkBox.id.slice(8,checkBox.id.length);

    if($('#' + checkBox.id).is(':checked'))
      Denwen.Track.action('Setting Turned On',{'Name' : name});
    else
      Denwen.Track.action('Setting Turned Off',{'Name' : name});
  },

  // Public. Display a success or failure message if an update
  // has been initiated.
  //
  displayFlashMessage: function() {
    if(Denwen.Flash.get('updated') == true) {
      Denwen.Drawer.success("Your changes have been saved.");
      Denwen.Track.action("Settings Updated");
    }
    else if(Denwen.Flash.get('updated') == false)
      Denwen.Drawer.error("Sorry, there was an error saving your changes.");
  },

  // Fire various tracking events
  //
  setAnalytics: function() {
    Denwen.Track.action("Settings View",{"Source" : this.source});

    if(this.source.slice(0,6) == 'email_')
      Denwen.Track.action("Unsubscribe Initiated",{
        "Source" : this.source.slice(6,this.source.length)});
  }

});

