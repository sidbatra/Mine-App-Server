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
    this.imagePathEl      = $('#store_image_path');
    this.imageContainerEl = $('#store_image');

    this.uploadConfig = this.options.uploadConfig;
    this.uploader = new Denwen.Partials.Common.Uploader({
                              el : $('#uploader'),
                          config : this.uploadConfig});

    this.uploader.bind(
      Denwen.Callbacks.Uploader.FileUploadDone,
      this.fileUploadDone,
      this);

    this.uploader.bind(
      Denwen.Callbacks.Uploader.FileUploadError,
      this.fileUploadError,
      this);
  },

  // Callback from uploader - file is uploaded
  //
  fileUploadDone: function(file,relativePath,absolutePath) {
    this.imagePathEl.val(relativePath);
    this.imageContainerEl.html("<img src='" + absolutePath + "' />");
  },

  // Callback from uploader - error uploading file
  //
  fileUploadError: function(message) {
    alert('Error uploading file: ' + message);
  }
});
