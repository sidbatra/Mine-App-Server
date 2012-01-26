// Manage interactions on a rendered collection preview
//
Denwen.Partials.Collections.Collection = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    var self      = this;

    this.source   = this.options.source;
    this.sourceID = this.options.sourceID;

    this.likes    = false;
    this.likeEl   = '#like_collection_' + this.model.get('id');

    $(this.likeEl).click(function(){self.likeClicked();});
  },

  // Create a like action on the current collection
  //
  createLike: function() {
    var action = new Denwen.Models.Action();

    action.save({
      name        : 'like',
      source_id   : this.model.get('id'),
      source_type : 'collection'});

    analytics.likeCreated(
                this.source,
                this.sourceID,
                this.model.get('id'),
                'collection',
                this.model.get('user_id'));
  },

  // User clicks the like button
  //
  likeClicked: function() {
    if(this.likes)
      return;

    $(this.likeEl).removeClass('');
    $(this.likeEl).addClass('');

    this.likes = true;

    this.createLike();
  }

});
