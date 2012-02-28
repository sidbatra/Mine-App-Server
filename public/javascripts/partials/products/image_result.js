// Partial for displaying a single image result
//
Denwen.Partials.Products.ImageResult = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.render();
  },

  // Override render method for displaying view
  //
  render: function() {
  
    var self      = this;
    var thumbUrl  = this.model.get('Thumbnail')['Url'];

    this.el.append(Denwen.JST['products/image_result']({
      thumbUrl:thumbUrl,
      filter:this.model.get('Filter')}));

    document.getElementById(thumbUrl).onclick = function(){self.clicked();};
  },

  // Fired when the image is clicked
  //
  clicked: function() {
    this.trigger('productImageClicked',this.model.infoHash());
  }
});

