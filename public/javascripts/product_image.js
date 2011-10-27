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
    this.offset = 0;
    this.query = query;

    this.fetchMedium(this.query);
    this.fetchLarge(this.query);

    var self = this;
    setTimeout(function(){self.searchMore();},2000);
  },

  searchMore: function() {
    this.offset += this.count;

    this.fetchMedium(this.query);
    this.fetchLarge(this.query);
  },

  parse: function(data) {
    var results = null;
    var query   = data['SearchResponse']['Query']['SearchTerms'];

    if(query != this.query)
      return results;

    var images = data['SearchResponse']['Image']['Results'];
    var offset = data['SearchResponse']['Image']['Offset'];

    //if(offset == 0 && !images)
    //  this.empty++;

    //if(this.empty == 2) {
    //  this.closeImagesBox();
    //  alert("Oops, no photos for this item. Try a different search, or upload a photo.");
    //}
    
    //if(!images)
    //  return results;

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
      $(this.imagesBoxEl).hide();
  },

  stopSearch: function() {
    $(this.imagesBoxEl).hide();
  },

  search: function() {
    var query = $(this.queryEl).val();
    
    $(this.imagesEl).html('');
    $(this.imagesBoxEl).show();

    this.images.search(query);
  },

  added: function(image) {
    new ProductImageView({model:image,el:$(this.imagesEl)});
  },

  searched: function() {
    
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

