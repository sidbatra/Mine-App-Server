// 
//
Denwen.Views.Welcome.Create = Backbone.View.extend({
  
  // Setup event handlers
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    var self = this;

    this.nextURL = this.options.nextURL;
    this.source = this.options.source;
    this.suggestions = new Denwen.Collections.Suggestions(
                            this.options.suggestions);

    this.cardsEl = '#cards';
    this.creationEl = '#creation';
    this.step1HeadingEl = '#step_1';
    this.step2HeadingEl = '#step_2';
    this.step3HeadingEl = '#step_3';
    this.tipEl = '#tip';
    this.exampleEl = '#example';
    this.caretEl = '#caret';

    this.input = new Denwen.Partials.Purchases.Input({
                        el  : $('body'),
                        scrollOnSelection : false,
                        resetOnCreation : false,
                        mode: Denwen.PurchaseFormType.New});

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


    this.suggestions.each(function(suggestion){
      $('#suggestion_' + suggestion.get('id')).click(function(){
        self.suggestionClicked(suggestion);
      });
    });


    this.setAnalytics();
  },

  // Fire tracking events
  //
  setAnalytics: function() {
    Denwen.Track.action("Welcome Create View",{"Source" : this.source});
    Denwen.Track.isEmailClicked(this.source);
  },

  // --
  // Callbacks from Suggestion Clicks
  // --
  suggestionClicked: function(suggestion) {
    $(this.tipEl).html(Denwen.JST['welcome/create/tip']({
                      thing:suggestion.get('thing')}));
    $(this.exampleEl).html(Denwen.JST['welcome/create/example']({
                      example:suggestion.get('example')}));
    $(this.step2HeadingEl).html(Denwen.JST['welcome/create/heading']({
                      thing:suggestion.get('thing')}));

    $(this.step1HeadingEl).hide();
    $(this.step2HeadingEl).show();

    $(this.cardsEl).hide();
    $(this.creationEl).show();

    this.input.queryPhocus();
    this.input.setSuggestion(suggestion.get('id'));

    Denwen.Track.action("Suggestion Card Clicked");
  },

  // --
  // Callbacks from Purchases.Input
  // --

  // Cleanup ui after a product has been selected.
  //
  productSelected: function(product) {
    $(this.step2HeadingEl).hide();
    $(this.step3HeadingEl).show();

    $(this.tipEl).hide();
    $(this.caretEl).hide();
    $(this.exampleEl).hide();
  },

  // Display the freshly created purchase in the feed.
  //
  purchaseCreated: function(purchase) {
    window.location.href = this.nextURL;
  },

  // Display a creation error.
  //
  purchaseCreationFailed: function() {
  }

});

