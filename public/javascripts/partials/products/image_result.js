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
    var id        = thumbUrl;

    /*var div = document.createElement("div");
    div.setAttribute('class','photo_choice_cell');

    div.innerHTML = "<img class='photo_choice' src='" + thumbUrl + "' />";

    div.onclick = function(){self.clicked();};
    this.el.append(div);*/
    
    this.el.append("<div id='" + id +"' class='photo_choice_cell'><img class='photo_choice' src='" + thumbUrl + "' /><div class='choose_this slim_shadow_dark'>Mine! or similar ›</div></div>");
    document.getElementById(id).onclick = function(){self.clicked();};
  },

  // Fired when the image is clicked
  //
  clicked: function() {
    this.trigger('productImageClicked',this.model.infoHash());
  }
});

