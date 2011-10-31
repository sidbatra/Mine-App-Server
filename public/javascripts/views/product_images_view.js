// View for displaying product image results 
// 
Denwen.ProductImagesView = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
    "click #product_search"   : "search",
    "keypress #product_query" : "queryKeystroke",
    "click #cancel_button"    : "stopSearch"
  },

  // Constructor logic
  //
  initialize: function() {
    var self          = this;

    this.queryEl      = "#product_query";
    this.imagesBoxEl  = "#chooser";
    this.imagesEl     = "#results";
    this.shadowEl     = "#shadow";

    this.images = this.options.images;
    this.images.bind('searched',this.searched,this);
    this.images.bind('add',this.added,this);
    
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
    if(e.which == 27 && this.isSearchActive())
      this.stopSearch();
  },

  // Hide the search UI
  //
  stopSearch: function() {
    $(this.shadowEl).fadeOut(500);
    $(this.imagesBoxEl).hide();
    $(this.shadowEl).css("height","100%");
  },

  // Launch the search UI
  //
  search: function() {
    var query = $(this.queryEl).val();

    if(!query.length)
      return;
    
    $(this.shadowEl).fadeIn(500);
    $(this.imagesEl).html('');
    $(this.imagesBoxEl).show();

    this.images.search(query);

    var search = new Denwen.Search({query:query});
    search.save();
  },

  // Fired when a product image is added to the images
  // collection. Here its added into the dom via its view
  //
  added: function(image) {
    var imageView =  new Denwen.ProductImageView({
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
    }
    else {
      this.resizeEnded();
    }

  },

  // Fired when the user selects a product image on a
  // ProductImageView
  //
  productImageClicked: function(productHash) {
    productHash['query'] = $(this.queryEl).val();
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

