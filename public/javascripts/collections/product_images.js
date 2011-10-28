Denwen.ProductImages = Backbone.Collection.extend({

  model: Denwen.ProductImage,

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
    this.disabled = 1;
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

    this.disabled = 1;
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
    this.disabled = 0;
    
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
