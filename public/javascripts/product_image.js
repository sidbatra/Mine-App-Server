var ProductImage = Backbone.Model.extend({

  initialize: function() {
  }

});


var ProductImages = Backbone.Collection.extend({

  model: ProductImage,

  initialize: function() {
    this.query = '';
    this.count = 12;
    this.offset = 0;
    this.state  = 0;
    this.disabled = 0;
  },

  url: function() {
    var url = [
                "http://api.bing.net/json.aspx?",
                "AppId=31862565CFBD51810ABE4AB2CEDCB80D52D33969&",
                "Version=2.2&",
                "Market=en-US&",
                "Query=" + encodeURIComponent(this.query) + "&",
                "Sources=Image+spell&",
                "Image.filters=" + this.size + "&",
                "Image.offset=" + this.offset + "&",
                "Image.count=" + this.count + "&",
                "JsonType=callback&",
                "JsonCallback=?"].join('');
    console.log(url);
    return url;
  },

  search: function(query) {
    this.reset();
    this.state = 0;
    this.offset = 0;
    this.disabled = 0;
    this.query = query;

    this.fetchMedium(this.query);
    this.fetchLarge(this.query);

    //var self = this;
    //setTimeout(function(){self.searchMore();},1);
    //setTimeout(function(){self.searchMore();},2000);
  },

  searchMore: function() {
    if(this.isSearching() || this.disabled)
      return;

    this.offset += this.count;

    this.fetchMedium(this.query);
    this.fetchLarge(this.query);
  },

  // Disable search to prevent any future searches
  //
  disableSearch: function() {
    this.disabled = 1; 
  },

  parse: function(data) {
    var results = [];
    var query   = data['SearchResponse']['Query']['SearchTerms'];

    if(query != this.query)
      return results;

    var images  = data['SearchResponse']['Image']['Results'];
    var offset  = data['SearchResponse']['Image']['Offset'];
    var total   = data['SearchResponse']['Image']['Total'];

    this.state++;
    
    if(total <=0)
      return results;

    results = images;
    
    return results;
  },

  fetchMedium: function(query) {
    var self = this;

    this.query = query;
    this.size = 'Size:Medium';
    this.fetch({
      add: true,
      dataType: "jsonp",
      success: function(d) { self.trigger('searched');},
      error: function(r,s,e){}});
  },

  fetchLarge: function(query) {
    var self = this;

    this.query = query;
    this.size = 'Size:Large';
    this.fetch({
      add: true,
      dataType: "jsonp",
      success: function(d) { self.trigger('searched');},
      error: function(r,s,e){}});
  },

  // Returns true if all active api searches haven't completed
  //
  isSearching: function() {
    return this.state % 2 != 0 || this.state == 0;
  },

  // Test if the requests have ended and the collection
  // is still empty
  //
  isEmpty: function() {
    return !this.isSearching() && this.length ==0;
  },

  // Test if the search has no more results to pull
  // from the remote server
  //
  isSearchDone: function() {
    return !this.isSearching() && this.length % this.count != 0;
  }

});


var ProductImagesView = Backbone.View.extend({

  events: {
    "click #product_search" : "search",
    "keypress #product_query" : "queryKeystroke",
    "click #chooser_closebox" : "stopSearch"
  },

  initialize: function() {
    var self = this;

    this.queryEl = "#product_query";
    this.imagesBoxEl = "#chooser";
    this.imagesEl = "#results";
    this.images = this.options.images;

    this.images.bind('searched',this.searched,this);
    this.images.bind('add',this.added,this);

    $('html').keydown(function(e){self.globalKeystroke(e);});

    $(this.queryEl).focus();
  },

  isSearchActive: function() {
    return $(this.imagesBoxEl).is(":visible");
  },

  queryKeystroke: function(e) {
    if(e.keyCode == 13) {
      this.search();
      return false;
    }
  },

  globalKeystroke: function(e) {
    if(e.which == 27 && this.isSearchActive())
      this.stopSearch();
  },

  stopSearch: function() {
    $(this.imagesBoxEl).hide();
  },

  search: function() {
    var query = $(this.queryEl).val();
    
    $(this.imagesEl).html('');
    $(this.imagesBoxEl).show();

    this.images.search(query);

    var search = new Search({query:query});
    search.save();
  },

  added: function(image) {
    new ProductImageView({model:image,el:$(this.imagesEl)});
  },

  searched: function() {
    if(this.images.isEmpty()) {
      this.stopSearch();
      this.images.disableSearch();
      alert("Oops, no photos for this item. Try a different search.");
    }
    else if(this.images.isSearchDone()) {
      this.images.disableSearch();
    }
  }

});

var ProductImageView = Backbone.View.extend({
  initialize: function() {
    this.render();
  },

  render: function() {
    var self = this;

    var thumbUrl = this.model.get('Thumbnail')['Url'];
    var id = thumbUrl;

    var div = document.createElement("div");
    div.setAttribute('class','photo_choice_cell');
    div.innerHTML = "<img class='photo_choice' src='" + thumbUrl + "' />";

    div.onclick = function(){self.clicked();};
    this.el.append(div);
  },

  // Fired when the image is clicked
  //
  clicked: function() {
    console.log(this.model.get('MediaUrl'));
  }
});

