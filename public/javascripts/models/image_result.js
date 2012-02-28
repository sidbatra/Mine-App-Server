// ImageResult represents an image
// returned when searching for images
//
Denwen.Models.ImageResult = Backbone.Model.extend({

  // Construtor logic
  //
  initialize: function() {
  },

  // Create a hash with the relevant info needed to
  // process the image result
  //
  infoHash: function() {
    return {
      "thumb_url"   : this.get('Thumbnail')['Url'],
      "website_url" : this.get('Url'),
      "image_url"   : this.get('MediaUrl'),
      "title"       : this.get('Title'),
      "from_url"    : this.get('Filter')
    };
  }

});


