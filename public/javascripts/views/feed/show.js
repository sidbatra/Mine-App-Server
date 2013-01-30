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

    this.inSearchMode = false;

    this.source = this.options.source;
    this.successEmailConnectURL = this.options.successEmailConnectURL;

    this.feedEl                   = '#feed';
    this.userSuggestionsEl        = '#user_suggestions_box';
    this.purchaseSearchInputEl    = '#purchase_search_data';
    this.purchaseSearchCrossEl    = '#purchase_search_cross';
    this.purchaseSearchMagGlassEl = '#purchase_search_mag_glass';
    this.purchaseSearchWrapperEl  = '#purchase_search_wrapper';
    
    //this.suggestionsEl    = '#suggestions';

    $(this.purchaseSearchInputEl).placeholder();
    $(this.purchaseSearchInputEl).focus();


    this.content  = new Denwen.Partials.Feed.Content({
                          aspect: 'user',
                          el:$(this.feedEl)});

    this.search  = new Denwen.Partials.Feed.Search({
                          el:$(this.feedEl)});
  

    this.input    = new Denwen.Partials.Purchases.Input({
                          el  : $('body'),
                          mode: Denwen.PurchaseFormType.New});

    this.input.bind(
      Denwen.Partials.Purchases.Input.Callback.PurchaseInitiated,
      this.purchaseInitiated,
      this);

    this.input.bind(
      Denwen.Partials.Purchases.Input.Callback.ProductSelected,
      this.productSelected,
      this);

    this.input.bind(
      Denwen.Partials.Purchases.Input.Callback.PurchaseCreated,
      this.purchaseCreated,
      this);

    this.input.bind(
      Denwen.Partials.Purchases.Input.Callback.PurchaseCreationFailed,
      this.purchaseCreationFailed,
      this);


    new Denwen.Partials.Users.Suggestions({
      el:$(this.userSuggestionsEl),
      perPage: 3});


    new Denwen.Partials.Auth.Email({
        el: '#body',
        googleEl: '#google_connect_button',
        yahooEl: '#yahoo_connect_button',
        hotmailEl: '#hotmail_connect_button',
        successURL: this.successEmailConnectURL});

    //this.suggestions = new Denwen.Partials.Feed.Suggestions({
    //                        el:$(this.suggestionsEl),
    //                        suggestionDelegate:this});


    //$("a[rel='tooltip']").tooltip();
    
    //this.loadFacebookPlugs();

    $(this.purchaseSearchCrossEl).click(function(){self.purchaseSearchCrossClicked()});
    $(this.purchaseSearchInputEl).keyup(function(e){self.purchaseSearchKeystroke(e)});


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
      Denwen.H.currentUser.get('id'),
      Denwen.H.currentUser.get('full_name'),
      Denwen.H.currentUser.get('email'),
      Denwen.H.currentUser.get('age'),
      Denwen.H.currentUser.get('gender'),
      Denwen.H.currentUser.get('created_at')); 
  },

  purchaseSearchKeystroke: function(e) {
    var text = $(this.purchaseSearchInputEl).val();

    if(text.length) { 
      $(this.purchaseSearchCrossEl).show();
      $(this.purchaseSearchMagGlassEl).addClass('active');
    }
    else {
      $(this.purchaseSearchCrossEl).hide();
      $(this.purchaseSearchMagGlassEl).removeClass('active');
    }

    if(e.which==13 && text.length > 2) {
      this.launchPurchaseSearch(text);
    }
  },

  purchaseSearchCrossClicked: function() {
    if(this.inSearchMode)
      this.stopPurchaseSearch();

    $(this.purchaseSearchInputEl).val('');
    $(this.purchaseSearchInputEl).focus();
    window.scrollTo(0,0)

    $(this.purchaseSearchCrossEl).hide();
  },

  launchPurchaseSearch: function(query) {
    if(!this.inSearchMode)
      this.content.disappear();

    this.inSearchMode = true;
    this.search.appear(query);

    $(this.purchaseSearchWrapperEl).attr("is_disabled",false);
    $(this.purchaseSearchWrapperEl).affix({
      offset: $(this.purchaseSearchWrapperEl).position()
    });
  },

  stopPurchaseSearch: function() {
    this.inSearchMode = false;

    this.search.disappear();
    this.content.appear();
    $(this.purchaseSearchCrossEl).hide();

    $(this.purchaseSearchWrapperEl).attr("is_disabled",true);
    $(this.purchaseSearchWrapperEl).removeClass('affix affix-top affix-bottom');
  },

  // --
  // Callbacks from Purchases.Input
  // --

  purchaseInitiated: function() {
  },

  productSelected: function() {
    //$(this.suggestionsEl).hide();
  },

  // Display the freshly created purchase in the feed.
  //
  purchaseCreated: function(purchase) {

    if(this.inSearchMode) {
      $(this.purchaseSearchInputEl).val('');
      this.stopPurchaseSearch();
    }

    this.content.insert(purchase);

    //if(this.suggestions.areActive()) {
    //  $(this.suggestionsEl).show();

    //  if(purchase.get('suggestion_id')) {
    //    Denwen.NM.trigger(
    //      Denwen.NotificationManager.Callback.SuggestionFinished,
    //      purchase.get('suggestion_id'));
    //  }
    //}

    Denwen.Track.action("Purchase Created");
  },

  // Display a creation error.
  //
  purchaseCreationFailed: function() {
  },

  // --
  // Callbacks from Feed.Suggestions
  // --

  suggestionClicked: function(suggestion) {
    this.input.setSuggestion(suggestion.get('id'));
    this.input.purchaseInitiated();

    Denwen.NM.trigger(
      Denwen.NotificationManager.Callback.SuggestionClicked,
      suggestion.get('id'));

    Denwen.Track.action("Suggestion Clicked"); 
  }


});
