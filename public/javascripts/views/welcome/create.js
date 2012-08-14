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
    this.currentSuggestionID = this.options.currentSuggestionID;
    this.extraSuggestion = new Denwen.Models.Suggestion(
                                this.options.extraSuggestion);
    this.suggestions = new Denwen.Collections.Suggestions(
                            this.options.suggestions);

		this.boxEl = '#box';
    this.cardsEl = '#cards';
    this.creationEl = '#creation';
    this.step1HeadingEl = '#step_1';
    this.step2HeadingEl = '#step_2';
    this.step3HeadingEl = '#step_3';
    this.exampleEl = '#example';
    this.extraSuggestionEl = '#extra_suggestion';
    this.extraSuggestionBoxEl = '#extra_suggestion_box';

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

    $(this.extraSuggestionEl).click(function(){
      self.suggestionClicked(self.extraSuggestion);
    });

    if(this.currentSuggestionID) {
      suggestion = this.suggestions.get(this.currentSuggestionID);

      if(suggestion)
        this.suggestionClicked(suggestion);
    }


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
    //$(this.exampleEl).html(Denwen.JST['welcome/create/example']({
    //                  example:suggestion.get('example')}));
    $(this.step2HeadingEl).html(Denwen.JST['welcome/create/heading']({
                      thing:suggestion.get('thing'),
                      example:suggestion.get('example')}));

    $(this.extraSuggestionBoxEl).hide();

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
  	$(this.boxEl).addClass('itemized');
    $(this.step2HeadingEl).hide();
    $(this.step3HeadingEl).show();

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

