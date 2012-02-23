// Manage interactions on a rendered collection preview
//
Denwen.Partials.Collections.Collection = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    var self      = this;

    this.source   = this.options.source;
    this.sourceID = this.options.sourceID;

    this.onClass  = 'pushed';
    this.likes    = false;
    this.likeEl   = '#like_collection_' + this.model.get('id');

    if(helpers.isLoggedIn())
      $(this.likeEl).click(function(){self.likeClicked();});
    else
      this.switchOn();
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
                this.model.get('user_id'));
  },

  // Switch on the like element to its clicked state
  //
  switchOn: function() {
    $(this.likeEl).addClass(this.onClass);
  },

  // User clicks the like button
  //
  likeClicked: function() {
    if(this.likes)
      return;

    this.switchOn();

    this.likes = true;

    this.createLike();
  }

});
