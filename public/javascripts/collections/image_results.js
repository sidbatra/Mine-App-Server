// Collection of ImageResult models holding image search results
//
Denwen.Collections.ImageResults = Backbone.Collection.extend({

  // Model name
  //
  model: Denwen.Models.ImageResult,

  // Constructor logic
  //
  initialize: function() {
    this.query      = '';
    this.count      = 12;
    this.offset     = 0;
    this.state      = 0;
    this.disabled   = 0;
    this.finished   = 0;
    this.queryType  = Denwen.ProductQueryType.Text;
  },

  // Create url to an image search api based on
  // the query, offset, size and count
  //
  url: function() {
    var url = '';
              
    if(this.queryType == Denwen.ProductQueryType.Text) { 
      url = [
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
    }
    else {
      url = "/parser?source=" + this.query;
    }

    trace(url);

    return url;
  },

  // Initiate a new search
  //
  search: function(query) {
    this.reset();

    this.state    = 0;
    this.offset   = 0;
    this.disabled = 1;
    this.finished = 0;
    this.query    = query;

    if(!this.query.match(/http/)) {
      this.queryType  = Denwen.ProductQueryType.Text;

      this.fetchMedium(this.query);
      this.fetchLarge(this.query);
    }
    else {
      this.queryType  = Denwen.ProductQueryType.URL;

      this.fetchImagesFromURL(this.query);
    }
  },

  // Load more results for the current search
  //
  searchMore: function() {
    if(this.isSearching() || this.disabled)
      return;

    this.disabled = 1;
    this.offset   += this.count;

    this.fetchMedium(this.query);
    this.fetchLarge(this.query);
  },

  // Disable search to prevent any future searches
  //
  disableSearch: function() {
    this.disabled = 1; 
  },

  // Parse out the results from the response before passing
  // it to the collection
  //
  parse: function(data) {
    var results = [];

    if(this.queryType == Denwen.ProductQueryType.Text) {
      var query   = data['SearchResponse']['Query']['SearchTerms'];

      if(query != this.query)
        return results;

      var images  = data['SearchResponse']['Image']['Results'];
      var offset  = data['SearchResponse']['Image']['Offset'];
      var total   = data['SearchResponse']['Image']['Total'];
      var spell   = data['SearchResponse']['Spell'];

      if(spell) {
        this.trigger('correction',spell['Results'][0]['Value']);
      }

      this.state++;
      this.disabled = 0;
      
      if(total <=0)
        return results;

      if(total - offset <= this.count) {
        this.finished++;
      }
        
      results = images;
    }
    else {
      var source = data['source'];
      var title  = data['title'];

      if(source != this.query)
        return results;

      var images = [];

      _.each(data['images'],function(image){
        var model = {
                      Thumbnail: {Url :image},
                      MediaUrl: image,
                      Url: source,
                      Title: title,
                      Filter: true}
        images.push(model);
      });

      this.state    = 2;
      this.finished = 2;

      results = images;
    }

    return results;
  },

  // Extract images from the given source url
  //
  fetchImagesFromURL: function(source) {
    var self = this;
    
    this.query = source;

    this.fetch({
      add :true,
      success:  function(d) { self.trigger('searched');},
      error:    function(r,s,e){}});
  },

  // Fetch medium sized search results from the images api
  //
  fetchMedium: function(query) {
    var self    = this;

    this.query  = query;
    this.size   = 'Size:Medium';

    this.fetch({
      add:      true,
      dataType: "jsonp",
      success:  function(d) { self.trigger('searched');},
      error:    function(r,s,e){}});
  },

  // Fetch large sized search results from the images api
  //
  fetchLarge: function(query) {
    var self    = this;

    this.query  = query;
    this.size   = 'Size:Large';

    this.fetch({
      add:      true,
      dataType: "jsonp",
      success:  function(d) { self.trigger('searched');},
      error:    function(r,s,e){}});
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
    return !this.isSearching() && this.finished >= 2;
  }

});
