// View for displaying the home page 
//
Denwen.Views.Home.Show = Backbone.View.extend({
  
  // Constructor logic
  //
  initialize: function() {
    this.tiles = $(".square.item");
    console.log(this.tiles);
    
    $('#tile_1').cycle({
        fx: 'fade' 
    });
  }

});
