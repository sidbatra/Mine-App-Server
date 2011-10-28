Denwen.ProductImageView = Backbone.View.extend({
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
    this.trigger('productImageClicked',this.model.productHash());
  }
});

