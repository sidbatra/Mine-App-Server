// View for selecting styles 
//
Denwen.Views.Styles.New = Backbone.View.extend({
  
  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self            = this;
    
    this.source         = this.options.source;
    this.styles         = new Denwen.Collections.Styles(this.options.styles);

    this.stylesEl       = '#styles';
    this.formEl         = '#new_styles';
    this.styleEl        = '#style';
    this.buttonEl       = '#styles_picked_button';

    this.posting        = false;
    this.style          = null; 
    this.stylePickers   = new Array();


    $(this.formEl).submit(function(){return self.post();});

    this.setup();
    this.setAnalytics();
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
  stylePicked: function(style) {
    var self    = this;
    this.style  = style;

    $.each(this.stylePickers,function(i,stylePicker){
      if(self.style.get('id') != stylePicker.model.get('id'))
        stylePicker.disable();
    });

    $(this.buttonEl).removeAttr('disabled'); 

    //analytics.stylePicked();
  },

  // Form submitted callback
  //
  post: function() {

    if(this.posting)
      return false;

    this.posting  = true;
    $(this.styleEl).val(this.style.get('caption'));

    return true;
  },

  // Fire tracking events
  //
  setAnalytics: function() {
  }

});
