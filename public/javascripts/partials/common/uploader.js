// Generic file uploader with callbacks
//
Denwen.Partials.Common.Uploader = Backbone.View.extend({

  // Event listeners
  //
  events: {
  },

  // Constructor logic
  //
  initialize: function() {
    this.config = this.options.config;

    this.setupSWFUpload();
  },

  // Setup the uploader object
  //
  setupSWFUpload: function()  {
    var self = this;
    this.uploader = new SWFUpload({

            // Backend Settings
            upload_url: this.config['server'],
            post_params: {"AWSAccessKeyId": this.config['aws_id'],
                          "acl": "public-read",
                          "key": this.config['key'] + "_${filename}",
                          "policy": this.config['policy'],
                          "signature": this.config['signature'],
                          "success_action_status":"201"},
            http_success : [201],

            // File Upload Settings
            file_post_name: 'file',
            file_size_limit : this.config['max'],
            file_types : this.config['extensions'],

            file_queued_handler: this.fileQueuedHandler.bind(this),
            upload_progress_handler: this.uploadProgressHandler.bind(this),
            upload_error_handler: this.uploadErrorHandler.bind(this),
            upload_success_handler: this.uploadSuccessHandler.bind(this),
            upload_complete_handler: this.uploadCompleteHandler.bind(this),

            // Button Settings
            button_placeholder_id : this.el.attr('id'),
            button_image_url: Denwen.H.imagePath('transparent.gif'),
            button_width: 350,
            button_height: 46,
            button_cursor: SWFUpload.CURSOR.HAND,
            button_window_mode: SWFUpload.WINDOW_MODE.TRANSPARENT,
            button_action : SWFUpload.BUTTON_ACTION.SELECT_FILE,
            
            // Flash Settings
            flash_url : Denwen.H.swfPath('swfupload.swf'),
            debug: false
          });

  },

  // Callback - file is selected
  //
  fileQueuedHandler: function(file) {
    this.trigger(Denwen.Partials.Common.Uploader.Callback.FileSelected,file);
    this.uploader.startUpload();
  },

  // Callback - progress of the upload
  //
  uploadProgressHandler: function(file,bytesLoaded) {
    var percent = Math.ceil((bytesLoaded / file.size) * 100);
    this.trigger(Denwen.Partials.Common.Uploader.Callback.FileUploadProgress,file,percent);
  },

  // Callback - file finished uploading (not 100% reliable)
  //
  uploadSuccessHandler: function(file,serverData) {
  },

  // Callback - file finished uploading (always called)
  //
  uploadCompleteHandler: function(file) {
    var relativePath = this.config['key'] + '_' + file.name;
    var absolutePath = this.config['server'] + relativePath;

    this.trigger(
      Denwen.Partials.Common.Uploader.Callback.FileUploadDone,
      file,
      relativePath,
      absolutePath);
  },
    
  // Callback - error uploading file
  //
  uploadErrorHandler: function(errorCode,message) {
    switch (errorCode) {
    case SWFUpload.UPLOAD_ERROR.FILE_CANCELLED:
      break;
    case SWFUpload.UPLOAD_ERROR.UPLOAD_STOPPED:
      break;
    default:
      break;
    }
    this.trigger(Denwen.Partials.Common.Uploader.Callback.FileUploadError,message);
  }

});

// Define callbacks.
//
Denwen.Partials.Common.Uploader.Callback = {
  FileSelected: 'fileSelected',
  FileUploadError: 'fileUploadError',
  FileUploadDone: 'fileUploadDone',
  FileUploadProgress: 'fileUploadProgress'
}
