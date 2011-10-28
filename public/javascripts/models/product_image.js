Denwen.ProductImage = Backbone.Model.extend({

  initialize: function() {
  },

  // Create a hash with the relevant info needed to
  // form a product model object
  //
  productHash: function() {
    return {
      "thumb_url" : this.get('Thumbnail')['Url'],
      "website_url" : this.get('Url'),
      "image_url" : this.get('MediaUrl')
    };
  }

});


