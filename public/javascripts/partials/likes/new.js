// Partial to create new like 
//
Denwen.Partials.Likes.New = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    var self          = this;

    this.productID    = this.options.product_id;
    this.posting      = false;

    this.buttonEl     = '#like_post_' + this.productID;

    $(this.buttonEl).click(function(){self.post();});
  },

  // Create a like 
  //
  post: function() {
    if(this.posting)
      return;

    var self      = this;
    this.posting  = true;

    var like = new Denwen.Models.Like({product_id : this.productID});

    like.save({},{
        success :  function(model) {self.created(model)},
        error   :  function(model,errors) {}
    });
  },

  // Called when the like is successfully created
  //
  created: function(like) {
    this.posting = false;
    
    if(like.get('user_id')) {
      new Denwen.Partials.Likes.Like({
            like  : like,
            el    : '#likes_' + this.productID}); 
      
      $(this.buttonEl).attr('disabled', true);
    }
  }

});
