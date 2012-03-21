// Partial for displaying image results 
// 
Denwen.Partials.Products.ImageResults = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
    "click #product_search"           : "search",
    "click #product_repeat_search"    : "search",
    "click #product_change_photo"     : "search",
    "keypress #product_query"         : "queryKeystroke",
    "keypress #product_repeat_query"  : "queryKeystroke",
    "click #cancel_button"            : "cancelButtonClicked"
  },

  // Constructor logic
  //
  initialize: function() {
    var self            = this;
    this.mode           = this.options.mode;

    this.loadClass      = "load";
    this.queryEl        = "#product_query";
    this.repeatQueryEl  = "#product_repeat_query";
    this.imagesBoxEl    = "#chooser";
    this.imagesEl       = "#results";
    this.shadowEl       = "#shadow";
    this.moreEl         = "#scroll_for_more_results";
    this.spinnerBoxEl   = "#spinner_box";

    this.images = new Denwen.Collections.ImageResults();
    this.images.bind(
      Denwen.Callback.ProductResultsLoaded,
      this.productResultsLoaded,
      this);
    this.images.bind(
      Denwen.Callback.ProductResultsEmpty,
      this.productResultsEmpty,
      this);
    this.images.bind(
      Denwen.Callback.ProductResultsFinished,
      this.productResultsFinished,
      this);
    this.images.bind(
      Denwen.Callback.ProductResultsQueryEdit,
      this.productResultsQueryEdit,
      this);
    this.images.bind(
      'add',
      this.productResultAdded,
      this);
    
    this.windowListener = new Denwen.WindowListener();
    this.windowListener.bind('documentScrolled',this.documentScrolled,this);
    this.windowListener.bind('resizeEnded',this.resizeEnded,this);

    $('html').keydown(function(e){self.globalKeystroke(e);});

    $(this.queryEl).focus();
  },

  // Test if the search box is still visible as a proxy
  // for search being in progress
  //
  isSearchActive: function() {
    return $(this.imagesBoxEl).is(":visible");
  },

  // Catch keystrokes on the query input to launch
  // search on enter
  //
  queryKeystroke: function(e) {
    if(e.keyCode == 13) {
      this.search();
      return false;
    }
  },

  // Catch global keystrokes to hide the search box
  // on escape
  //
  globalKeystroke: function(e) {
    if(e.which == 27 && this.isSearchActive()) {
      this.stopSearch();
      this.trigger('productSearchCancelled','escape');
    }
  },

  // Fired when the user clicks the cancel butotn
  //
  cancelButtonClicked: function() {
    this.stopSearch();
    this.trigger('productSearchCancelled','cross');
  },

  // Hide the search UI
  //
  stopSearch: function() {
    $(this.shadowEl).fadeOut(500);
    $(this.imagesBoxEl).hide();
    $(this.queryEl).val($(this.repeatQueryEl).val());
    $(this.repeatQueryEl).val('');
  },

  // Enter into spinning mode
  //
  startSpinner: function() {
    $(this.spinnerBoxEl).addClass(this.loadClass);
  },

  // Exit from spinner mode
  //
  stopSpinner: function() {
    $(this.spinnerBoxEl).removeClass(this.loadClass);
  },

  // Launch the search UI
  //
  search: function() {
    var query = $(this.repeatQueryEl).val();
    
    if(!query.length) {
      query = $(this.queryEl).val();
      $(this.repeatQueryEl).val(query);
    }

    if(!query.length)
      return;

    this.startSpinner();

    $(this.shadowEl).css("height","100%");
    $(this.shadowEl).fadeIn(500);
    $(this.imagesEl).html('');
    $(this.imagesBoxEl).show();
    $(this.moreEl).show();
    $(this.repeatQueryEl).focus();
    $(this.repeatQueryEl).val($(this.repeatQueryEl).val());

    this.images.search(query);

    var search = new Denwen.Models.Search({
                      query   : query,
                      source  : this.mode == 'new' ? 0 : 1});

    setTimeout(function(){search.save();},500);

    this.trigger('productSearched',query,this.images.queryType);
  },

  // Fired when a product result is added to the result
  // collection. Here its added into the dom via its view
  //
  productResultAdded: function(productResult) {
    var imageView =  new Denwen.Partials.Products.ImageResult({
                          model:productResult,
                          imageTest:this.images.isURLQuery(),
                          el:$(this.imagesEl)});
    imageView.bind('productImageClicked',this.productImageClicked,this);
  },

  // Callback whenever product search results are loaded
  //
  productResultsLoaded: function() {
    this.stopSpinner();
    $(this.shadowEl).css("height", $(document).height());
    this.resizeEnded();
  },

  // Callback when no product search results are found
  //
  productResultsEmpty: function() {
    this.stopSearch();
    dDrawer.error("Oops, no photos for this item. Try a different search.");
  },

  // Callback when no more product search results are left
  //
  productResultsFinished: function() {
    $(this.moreEl).hide();
  },

  // Callback when there is a correction to the user query
  //
  productResultsQueryEdit: function(query) {
    $(this.repeatQueryEl).val(query);
  },

  // Fired when the user selects a product image on a
  // ProductImageView
  //
  productImageClicked: function(productResult) {
    this.trigger(
      'productSelected',
      productResult,
      this.images.currentSearchTitle(),
      this.images.isURLQuery());
    this.stopSearch();
  },

  // Infinite scroll callback fired when user has 
  // scrolled to the end of the page
  //
  documentScrolled: function() {
    if(this.isSearchActive())
      this.images.searchMore();
  },

  // Browser window resize ended callback
  //
  resizeEnded: function() {
    if(this.isSearchActive() && this.windowListener.isWindowEmpty()) 
      this.images.searchMore();
  }

});

