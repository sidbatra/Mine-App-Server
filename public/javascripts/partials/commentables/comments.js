// Partial to load, display and create comments for
// either a product or a collection
//
Denwen.Partials.Commentables.Comments = Backbone.View.extend({

  // Setup event handlers
  //
  events: {
    "click #comment_post"  : "post"
  },

  // Constructor logic
  //
  initialize: function() {
    var self                = this;

    this.posting            = false;
    this.commentableID      = this.options.commentable_id;
    this.commentableType    = this.options.commentable_type;

    this.inputEl            = '#comment_data';
    this.commentsEl         = '#comments';
    this.commentPlaceholder = $(this.inputEl).val();

    this.comments           = new Denwen.Collections.Comments();
    this.comments.fetch({
            data      : {
                          source_id   : this.commentableID,
                          source_type : this.commentableType},
            success   : function() { self.render(); },
            error     : function() {}
          });

    make_conditional_field(
      this.inputEl,
      $(this.inputEl).val(),
      $(this.inputEl).css('color'),
      '#333333');
  },

  // Render the comments collection
  //
  render: function() {
    var self = this;

    this.comments.each(function(comment){
      $(self.commentsEl).append(Denwen.JST['comments/comment']({
                                    comment:comment}));
    });
  },

  // Creates a comment
  //
  post: function() {
    if(this.posting)
      return;

    var self      = this;
    this.posting  = true;

    var comment   = new Denwen.Models.Comment({
                          data        : $(this.inputEl).val(),
                          source_id   : this.commentableID,
                          source_type : this.commentableType,
                          defaultData : this.commentPlaceholder});

    this.comments.add(comment);

    comment.save({
          data    :  $(this.inputEl).val()}, { 
          success :  function(model) {self.created(model)},
          error   :  function(model,errors) {}
      });

    analytics.commentCreated(this.commentableID,this.commentableType);
  },

  // Called when the comment is successfully created
  //
  created: function(comment) {
    this.posting = false;

    $(this.commentsEl).append(Denwen.JST['comments/comment']({
                                  comment:comment}));

    $(this.inputEl).val('');
    $(this.inputEl).focus();
  }

});
