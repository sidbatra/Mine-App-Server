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
    this.divID    = Math.random().toString(36).substring(7);

    this.el.append(Denwen.JST['products/image_result']({
      thumbUrl:thumbUrl,
         divID:this.divID,
          hide:this.model.get('Filter')}));

    this.divEl = $('#' + this.divID);

    this.divEl.click(function(){self.clicked();});

    if(this.model.get('Filter'))
      this.divEl.find("img").load(function(){self.imageLoaded(this)});
  },

  // Fired when the image is clicked
  //
  clicked: function() {
    this.trigger('productImageClicked',this.model.infoHash());
  },

  // Fired when the image is loaded
  //
  imageLoaded: function(image) {
    var aspectRatio = image.width / image.height;

    if(image.width > 149 && 
        image.height > 149 &&
        aspectRatio < 3 &&
        aspectRatio > 0.3)
        this.divEl.show();
  }
});

