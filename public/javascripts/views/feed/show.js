// View for displaying a user's feed.
//
Denwen.Views.Feed.Show = Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self = this;

    this.source       = this.options.source;
    this.currentUser  = new Denwen.Models.User(this.options.currentUserJSON);

    this.feedEl = '#feed';
    this.suggestionsEl = '#suggestions';

    this.content  = new Denwen.Partials.Feed.Content({el:$(this.feedEl)});
    this.input    = new Denwen.Partials.Purchases.Input({
                          el  : $('body'),
                          mode: Denwen.PurchaseFormType.New});

    this.input.bind(
      Denwen.Partials.Purchases.Input.Callback.PurchaseInitiated,
      this.purchaseInitiated,
      this);

    this.input.bind(
      Denwen.Partials.Purchases.Input.Callback.PurchaseCreated,
      this.purchaseCreated,
      this);

    this.input.bind(
      Denwen.Partials.Purchases.Input.Callback.PurchaseCreationFailed,
      this.purchaseCreationFailed,
      this);


    this.suggestions = new Denwen.Partials.Feed.Suggestions({
                            el:$(this.suggestionsEl),
                            suggestionDelegate:this});


    $("a[rel='tooltip']").tooltip();
    
    this.loadFacebookPlugs();

    this.setAnalytics();
  },

  // Load facebook code via partials
  //
  loadFacebookPlugs: function() {
    new Denwen.Partials.Facebook.Base();
  },

  // Fire various tracking events
  //
  setAnalytics: function() {
    Denwen.Track.action("Feed View",{"Source" : this.source});

    if(this.source == 'login')
      Denwen.Track.action("User Logged In");
    else if(this.source == 'welcome')
      Denwen.Track.action("Purchase Created");
      

    Denwen.Track.version(Denwen.H.version);
    Denwen.Track.isEmailClicked(this.source);

    Denwen.Track.user(
      Denwen.H.currentUser.get('email'),
      Denwen.H.currentUser.get('age'),
      Denwen.H.currentUser.get('gender')); 
  },

  // --
  // Callbacks from Purchases.Input
  // --

  purchaseInitiated: function() {
    $(this.suggestionsEl).hide();
  },

  // Display the freshly created purchase in the feed.
  //
  purchaseCreated: function(purchase) {
    this.content.insert(purchase);

    if(this.suggestions.areActive()) {
      $(this.suggestionsEl).fadeIn(250);

      if(purchase.get('suggestion_id'))
        console.log('with id');
    }

    Denwen.Track.action("Purchase Created");
  },

  // Display a creation error.
  //
  purchaseCreationFailed: function() {
    //console.log("Error creating purchase");
  },

  // --
  // Callbacks from Feed.Suggestions
  // --

  suggestionClicked: function(suggestion) {
    $(this.suggestionsEl).hide();

    this.input.setSuggestion(suggestion.get('id'));
    this.input.purchaseInitiated();

    Denwen.Track.action("Suggestion Clicked"); 
  }


});
