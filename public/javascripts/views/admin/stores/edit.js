// View editing a store
//
Denwen.Views.Admin.Stores.Edit = Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.imagePathEl        = $('#store_image_path');
    this.imageContainerEl   = $('#store_image');
    this.faviconPathEl      = $('#store_favicon_path');
    this.faviconContainerEl = $('#store_favicon');

    this.uploadConfig = this.options.uploadConfig;

    this.imageUploader = new Denwen.Partials.Common.Uploader({
                              el : $('#image_uploader'),
                          config : this.uploadConfig});

    this.faviconUploader = new Denwen.Partials.Common.Uploader({
                                el : $('#favicon_uploader'),
                            config : this.uploadConfig});

    this.imageUploader.bind(
      Denwen.Callbacks.Uploader.FileUploadDone,
      this.imageUploadDone,
      this);

    this.faviconUploader.bind(
      Denwen.Callbacks.Uploader.FileUploadDone,
      this.faviconUploadDone,
      this);

    this.imageUploader.bind(
      Denwen.Callbacks.Uploader.FileUploadError,
      this.fileUploadError,
      this);

    this.faviconUploader.bind(
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

  // Callback from faviconUploader - file is uploaded
  //
  faviconUploadDone: function(file,relativePath,absolutePath) {
    this.faviconPathEl.val(relativePath);
    this.faviconContainerEl.html("<img src='" + absolutePath + "' />");
  },

  // Callback from both uploaders - error uploading file
  //
  fileUploadError: function(message) {
    alert('Error uploading file: ' + message);
  }
});
