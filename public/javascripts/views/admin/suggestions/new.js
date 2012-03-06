// View for creating a new suggestion
//
Denwen.Views.Admin.Suggestions.New = Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.imagePathEl        = $('#suggestion_image_path');
    this.imageContainerEl   = $('#suggestion_image');

    this.uploadConfig = this.options.uploadConfig;

    this.imageUploader = new Denwen.Partials.Common.Uploader({
                              el : $('#image_uploader'),
                          config : this.uploadConfig});

    this.imageUploader.bind(
      Denwen.Callbacks.Uploader.FileUploadDone,
      this.imageUploadDone,
      this);

    this.imageUploader.bind(
      Denwen.Callbacks.Uploader.FileUploadError,
      this.fileUploadError,
      this);
  },

  // Callback from imageUploader - file is uploaded
  //
  imageUploadDone: function(file,relativePath,absolutePath) {
    this.imagePathEl.val(relativePath);
    this.imageContainerEl.html("<img src='" + absolutePath + "' />");
  },

  // Callback from uploader - error uploading file
  //
  fileUploadError: function(message) {
    dDrawer.error('Error uploading file: ' + message);
  }
});
