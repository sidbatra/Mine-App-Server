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
    this.styleEl        = '#style_id';
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

    $(this.buttonEl).addClass('btn-primary');
    $(this.buttonEl).removeAttr('disabled'); 
    $(this.buttonEl).html(
      "Pick your Stores <i class='icon-chevron-right icon-white'></i>"); 

    analytics.stylePicked();
  },

  // Form submitted callback
  //
  post: function() {

    if(this.posting)
      return false;

    this.posting  = true;
    $(this.styleEl).val(this.style.get('id'));

    return true;
  },

  // Fire tracking events
  //
  setAnalytics: function() {

    if(helpers.isOnboarding)
      analytics.styleViewOnboarding();
    else
      analytics.styleView(this.source);
  }

});
