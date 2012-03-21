// Partial for choosing styles
//
Denwen.Partials.Invites.New.Styles = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.styles       = this.options.styles;
    this.buttonEl     = '#styles_picked_button';

    this.stylePickers = new Array();

    this.setup();
  },

  // Fired just before the sub view comes into focus
  //
  display: function() {
  },

  // Setup pick/unpick functionality for all styles 
  //
  setup: function(){
    var self = this;

    this.styles.each(function(style){
      var stylePicker = new Denwen.Partials.Styles.Picker({
                                        model : style,
                                        el    : $(self.stylesEl)
                                        });

      stylePicker.bind(
        'stylePicked',
        self.stylePicked,
        self);

      self.stylePickers.push(stylePicker);
    });
  },

  // Fired when a style is picked
  //
  stylePicked: function(styleID) {
    var self      = this;
    this.styleID  = styleID;

    $.each(this.stylePickers,function(i,stylePicker) {
      if(self.styleID != stylePicker.model.get('id'))
        stylePicker.disable();
      else
        stylePicker.enable();
    });

    $(this.buttonEl).attr('href','#styles-' + this.styleID + '/friends');
    $(this.buttonEl).addClass('btn-primary');
    $(this.buttonEl).removeAttr('disabled'); 
    $(this.buttonEl).html(
      "Next <i class='icon-chevron-right icon-white'></i>"); 

    analytics.stylePicked();
  }

});
