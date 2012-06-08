// Partial for displaying a single product
//
Denwen.Partials.Products.Product = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    this.render();
  },

  // Override render method for displaying view
  //
  render: function() {
    var self        = this;
    var thumbUrl    = this.model.get('medium_url');
    this.imageTest  = this.options.imageTest;
    this.divID      = Math.random().toString(36).substring(7);

    this.el.append(Denwen.JST['products/product']({
      thumbUrl:thumbUrl,
         divID:this.divID,
          hide:this.imageTest}));

    this.divEl = $('#' + this.divID);

    this.divEl.click(function(){self.clicked();});

    if(this.imageTest)
      this.divEl.find("img").load(function(){self.imageLoaded(this)});
  },

  // Fired when the image is clicked
  //
  clicked: function() {
    this.trigger(Denwen.Partials.Products.Product.Callback.Clicked,this.model);
  },

  // Fired when the image is loaded
  //
  imageLoaded: function(image) {
    var aspectRatio = image.width / image.height;

    if((!image.width && !image.height) || (
        (image.width > 149 || image.height > 149) &&
        aspectRatio < 3 &&
        aspectRatio > 0.3))
        this.divEl.show();
  }
});

// Define callbacks.
//
Denwen.Partials.Products.Product.Callback = {
  Clicked : 'clicked'
}
