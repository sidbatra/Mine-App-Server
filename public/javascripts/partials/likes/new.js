// Partial to create new like 
//
Denwen.Partials.Likes.New = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    var self          = this;

    this.purchase     = this.options.purchase;
    this.posting      = false;

    this.buttonEl     = this.el.find('.sel-purchase-create-like');

    $(this.buttonEl).click(function(){self.post(true);});
  },

  // Create a like 
  //
  post: function(render) {
    if(this.posting)
      return;

    var self      = this;
    this.posting  = true;

    var like = new Denwen.Models.Like({purchase_id : this.purchase.get('id')});

    like.save({},{
        success :  function(model) {self.created(model)},
        error   :  function(model,errors) {}
    });

    if(render)
      this.render(like);

    this.disable();
  },

  // Render the like before sending the request to the server 
  //
  render: function(like) {
    Denwen.NM.trigger(Denwen.NotificationManager.Callback.LikeCreated,like);
  },

  // Called when the like is successfully created
  //
  created: function(like) {
    this.posting = false;

    if(!like.get('id')) {
      this.enable();
      Denwen.Drawer.error("Error posting like. Try again in a second.");
    }
    else {
      Denwen.Track.action("Like Created");
    }
  },

  // Disable the button if a user likes/has liked an item
  //
  disable: function() {
    $(this.buttonEl).addClass('pushed');
    $(this.buttonEl).unbind('click');
  },

  // Enable the button in error cases 
  //
  enable: function() {
    var self = this;

    $(this.buttonEl).removeClass('pushed');
    $(this.buttonEl).bind('click',function(){self.post(false);});
  }

});
