// Partial for creating or editing a style
//
Denwen.Partials.Admin.Styles.Input = Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.imagePathEl        = $('#style_image_path');
    this.imageContainerEl   = $('#style_image');

    this.uploadConfig = this.options.uploadConfig;

    this.imageUploader = new Denwen.Partials.Common.Uploader({
                              el : $('#image_uploader'),
                          config : this.uploadConfig});

    this.imageUploader.bind(
      Denwen.Callback.FileUploadDone,
      this.imageUploadDone,
      this);

    this.imageUploader.bind(
      Denwen.Callback.FileUploadError,
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
