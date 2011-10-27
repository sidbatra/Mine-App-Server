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
    this.query = query;

    this.fetchMedium(this.query);
    this.fetchLarge(this.query);
  },

  searchMore: function() {
    this.offset += this.count;

    this.fetchMedium(this.query);
    this.fetchLarge(this.query);
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

  // Test if the requests have ended and the collection
  // is still empty
  //
  isEmpty: function() {
    return this.state % 2 == 0 && this.length ==0;
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
      alert("Oops, no photos for this item. Try a different search, or upload a photo.");
    }
  }

});

var ProductImageView = Backbone.View.extend({
  initialize: function() {
    this.render();
  },

  render: function() {
    var thumbUrl = this.model.get('Thumbnail')['Url'];
    var id = thumbUrl;

    var html = [
          "<div class='photo_choice_cell' ",
          "onclick=\"productSelected('" + id + "')\">",
          "<img class='photo_choice' ",
          "src='" + thumbUrl + "' ",
          "/></div>"].join('');

    this.el.append(html);
  }
});

