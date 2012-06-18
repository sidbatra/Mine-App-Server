// Partial for creating or editing a suggestion
//
Denwen.Partials.Admin.Suggestions.Input = Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.imagePathEl = $('#suggestion_image_path');
    this.smallImagePathEl = $('#suggestion_small_image_path');
    this.imageContainerEl = $('#suggestion_image');
    this.smallImageContainerEl = $('#suggestion_small_image');

    this.uploadConfig = this.options.uploadConfig;

    this.imageUploader = new Denwen.Partials.Common.Uploader({
                              el : $('#image_uploader'),
                          config : this.uploadConfig});

    this.imageUploader.bind(
      Denwen.Partials.Common.Uploader.Callback.FileUploadDone,
      this.imageUploadDone,
      this);

    this.imageUploader.bind(
      Denwen.Partials.Common.Uploader.Callback.FileUploadError,
      this.fileUploadError,
      this);
 

    this.smallImageUploader = new Denwen.Partials.Common.Uploader({
                              el : $('#small_image_uploader'),
                          config : this.uploadConfig});

    this.smallImageUploader.bind(
      Denwen.Partials.Common.Uploader.Callback.FileUploadDone,
      this.smallImageUploadDone,
      this);

    this.smallImageUploader.bind(
      Denwen.Partials.Common.Uploader.Callback.FileUploadError,
      this.fileUploadError,
      this);
  },

  // Callback from imageUploader - large file is uploaded
  //
  imageUploadDone: function(file,relativePath,absolutePath) {
    this.imagePathEl.val(relativePath);
    this.imageContainerEl.html("<img src='" + absolutePath + "' />");
  },

  // Callback from imageUploader - small file is uploaded
  //
  smallImageUploadDone: function(file,relativePath,absolutePath) {
    this.imagePathEl.val(relativePath);
    this.smallImageContainerEl.html("<img src='" + absolutePath + "' />");
  },

  // Callback from uploader - error uploading file
  //
  fileUploadError: function(message) {
    Denwen.Drawer.error('Error uploading file: ' + message);
  }
});
