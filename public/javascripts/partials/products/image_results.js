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

    this.queryEl        = "#product_query";
    this.repeatQueryEl  = "#product_repeat_query";
    this.imagesBoxEl    = "#chooser";
    this.imagesEl       = "#results";
    this.shadowEl       = "#shadow";
    this.moreEl         = "#scroll_for_more_results";

    this.images = this.options.images;
    this.images.bind('searched',this.searched,this);
    this.images.bind('add',this.added,this);
    this.images.bind('correction',this.queryCorrection,this);
    
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

  // Fired from the images collection when there is a correction
  //
  queryCorrection: function(correctedQuery) {
    $(this.repeatQueryEl).val(correctedQuery);
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

  // Fired when a product image is added to the images
  // collection. Here its added into the dom via its view
  //
  added: function(image) {
    var imageView =  new Denwen.Partials.Products.ImageResult({
                          model:image,
                          el:$(this.imagesEl)});
    imageView.bind('productImageClicked',this.productImageClicked,this);
  },

  // Fired when a set of results have been returned to the images
  // collection. Used to catch edge cases like no results or no
  // more results
  //
  searched: function() {
    $(this.shadowEl).css("height", $(document).height());

    if(this.images.isEmpty()) {
      this.stopSearch();
      this.images.disableSearch();
      alert("Oops, no photos for this item. Try a different search.");
    }
    else if(this.images.isSearchDone()) {
      this.images.disableSearch();
      $(this.moreEl).hide();
    }
    else {
      this.resizeEnded();
    }

  },

  // Fired when the user selects a product image on a
  // ProductImageView
  //
  productImageClicked: function(productHash) {
    productHash['query'] = productHash['from_url'] ? 
                            productHash['title'] :
                            $(this.repeatQueryEl).val();
    this.trigger('productSelected',productHash);
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

