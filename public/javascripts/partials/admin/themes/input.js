// Partial for creating or editing a theme
//
Denwen.Partials.Admin.Themes.Input = Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.backgroundPathEl = $('#theme_background_path');
    this.backgroundTilePathEl = $('#theme_background_tile_path');
    this.backgroundImageContainerEl = $('#background_image');
    this.backgroundTileImageContainerEl = $('#background_tile_image');

    this.uploadConfig = this.options.uploadConfig;

    this.backgroundUploader = new Denwen.Partials.Common.Uploader({
                              el : $('#background_uploader'),
                          config : this.uploadConfig});

    this.backgroundUploader.bind(
      Denwen.Partials.Common.Uploader.Callback.FileUploadDone,
      this.backgroundUploadDone,
      this);

    this.backgroundUploader.bind(
      Denwen.Partials.Common.Uploader.Callback.FileUploadError,
      this.fileUploadError,
      this);
 

    this.backgroundTileImageUploader = new Denwen.Partials.Common.Uploader({
                              el : $('#background_tile_uploader'),
                          config : this.uploadConfig});

    this.backgroundTileImageUploader.bind(
      Denwen.Partials.Common.Uploader.Callback.FileUploadDone,
      this.backgroundTileUploadDone,
      this);

    this.backgroundTileImageUploader.bind(
      Denwen.Partials.Common.Uploader.Callback.FileUploadError,
      this.fileUploadError,
      this);
  },

  // Callback from backgroundUploader - large file is uploaded
  //
  backgroundUploadDone: function(file,relativePath,absolutePath) {
    this.backgroundPathEl.val(relativePath);
    this.backgroundImageContainerEl.html("<img src='" + absolutePath + "' />");
  },

  // Callback from backgroundUploader - small file is uploaded
  //
  backgroundTileUploadDone: function(file,relativePath,absolutePath) {
    this.backgroundTilePathEl.val(relativePath);
    this.backgroundTileImageContainerEl.html("<img src='" + absolutePath + "' />");
  },

  // Callback from uploader - error uploading file
  //
  fileUploadError: function(message) {
    Denwen.Drawer.error('Error uploading file: ' + message);
  }
});
