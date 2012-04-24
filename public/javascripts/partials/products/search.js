Denwen.Partials.Products.Search = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
    "click #purchase_search"           : "search",
    "click #purchase_repeat_search"    : "search",
    "click #purchase_change_photo"     : "changePhotoClicked",
    "keypress #purchase_query"         : "queryKeystroke",
    "keypress #purchase_repeat_query"  : "queryKeystroke",
    "click #cancel_button"             : "cancelButtonClicked"
  },

  // Constructor logic
  //
  initialize: function() {
    var self            = this;
    this.mode           = this.options.mode;

    this.loadClass      = "load";
    this.queryEl        = "#purchase_query";
    this.repeatQueryEl  = "#purchase_repeat_query";
    this.productsBoxEl  = "#chooser";
    this.productsEl     = "#results";
    this.shadowEl       = "#shadow";
    this.moreEl         = "#scroll_for_more_results";
    this.spinnerBoxEl   = "#spinner_box";

    this.products = new Denwen.Collections.Products();
    this.products.bind(
      Denwen.Collections.Products.Callback.Loaded,
      this.productsLoaded,
      this);
    this.products.bind(
      Denwen.Collections.Products.Callback.Empty,
      this.productsNotFound,
      this);
    this.products.bind(
      Denwen.Collections.Products.Callback.Finished,
      this.productsFinished,
      this);
    this.products.bind(
      Denwen.Collections.Products.Callback.QueryFixed,
      this.productQueryFixed,
      this);
    this.products.bind(
      'add',
      this.productAdded,
      this);
    
    this.infiniteScroller = new Denwen.InfiniteScroller({
                                element:this.productsEl});

    this.infiniteScroller.bind(
      Denwen.InfiniteScroller.Callback.EndReached,
      this.endReached,
      this);

    this.infiniteScroller.bind(
      Denwen.InfiniteScroller.Callback.EmptySpaceFound,
      this.emptySpaceFound,
      this);

    $('html').keydown(function(e){self.globalKeystroke(e);});

    $(this.queryEl).placeholder();

    if($.support.placeholder)
      $(this.queryEl).focus();
  },

  // Display loading spinner on search more
  //
  enterSearchMoreLoading: function() {
    $(this.moreEl).addClass(this.loadClass);
  },

  // Test if the search box is still visible as a proxy
  // for search being in progress
  //
  isSearchActive: function() {
    return $(this.productsBoxEl).is(":visible");
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
    $("body").css("overflow","auto");

    $(this.shadowEl).fadeOut(500);
    $(this.productsBoxEl).hide();
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
    $(this.moreEl).removeClass(this.loadClass);
  },

  // Fired when the change photo element is clicked. Launch
  // search with an extra parameter.
  //
  changePhotoClicked: function() {
    this.search(true);
  },

  // Launch the search UI
  //
  search: function(changePhoto) {
    var query = $(this.repeatQueryEl).val();
    
    if(!query.length) {
      query = $(this.queryEl).val();
      $(this.repeatQueryEl).val(query);
    }

    if(!query.length || query == $(this.queryEl).attr('placeholder')) {
      $(this.repeatQueryEl).val('');
      return;
    }

    if(!changePhoto && query.match(/http.*(.jpg|.jpeg|.gif|.png|.bmp|.tif)$/)){
      var productResult = new Denwen.Models.Product({
                                medium_url: query,
                                large_url: query,
                                source_url: query,
                                title : "",
                                uniq_id : ""});
      this.productImageClicked(productResult);
      return;
    }

    $("body").css("overflow","hidden");

    this.startSpinner();

    $(this.shadowEl).css("height","100%");
    $(this.shadowEl).fadeIn(500);
    $(this.productsEl).html('');
    $(this.productsBoxEl).show();
    $(this.moreEl).show();
    $(this.repeatQueryEl).focus();
    $(this.repeatQueryEl).val($(this.repeatQueryEl).val());

    this.products.search(query);

    var search = new Denwen.Models.Search({
                      query   : query,
                      source  : this.mode == 'new' ? 0 : 1});

    setTimeout(function(){search.save();},750);

    this.trigger('productSearched',query,this.products.queryType);
  },


  //
  // Callbacks from products collection.
  //

  // Fired when a product result is added to the result
  // collection. Here its added into the dom via its view
  //
  productAdded: function(productResult) {
    var imageView =  new Denwen.Partials.Products.Product({
                          model:productResult,
                          imageTest:this.products.isURLQuery(),
                          el:$(this.productsEl)});
    imageView.bind(
      Denwen.Partials.Products.Product.Callback.Clicked,
      this.productImageClicked,
      this);
  },

  // Callback whenever product search results are loaded
  //
  productsLoaded: function() {
    this.stopSpinner();
    $(this.shadowEl).css("height", $(document).height());

    this.infiniteScroller.emptySpaceTest();

    if(this.products.isURLQuery() && !this.products.isEmpty()) {
      var self = this;
      setTimeout(function(){
        if(!$(self.productsEl).find("img:visible").length && 
            self.isSearchActive())
          Denwen.Drawer.error("Oops, no products found. Try a different URL.");
        },1500);
    }
  },

  // Callback when no product search results are found
  //
  productsNotFound: function() {
    //this.stopSearch();
    Denwen.Drawer.error("Oops, no products found. Try a different search.");
  },

  // Callback when no more product search results are left
  //
  productsFinished: function() {
    $(this.moreEl).hide();
  },

  // Callback when there is a correction to the user query
  //
  productQueryFixed: function(query) {
    $(this.repeatQueryEl).val(query);
  },

  // Fired when the user selects a product image on a
  // ProductImageView
  //
  productImageClicked: function(product) {
    this.trigger(
      'productSelected',
      product,
      this.products.currentSearchTitle(),
      this.products.isURLQuery());
    this.stopSearch();
  },


  //
  // Callbacks from infinite scroller.
  //

  // Infinite scroll callback fired when user has 
  // scrolled to the end of the element.
  //
  endReached: function() {
    if(this.isSearchActive()) {
      this.products.searchMore();
      this.enterSearchMoreLoading();
    }
  },

  // Infinite scroller callback when the element hasn't filled out
  // its fixed height.
  //
  emptySpaceFound: function() {
    if(this.isSearchActive()) {
      this.products.searchMore();
      this.enterSearchMoreLoading();
    }
  }

});

