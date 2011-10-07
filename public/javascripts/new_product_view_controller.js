// NewProductViewController provides a javascript interface for
// creating a new product

// UI elements 
var kProductForm        = '#new_product';
var kProductTitle       = '#product_title';
var kProductEndorsement = '#product_endorsement';
var kProductQuery       = '#product_query';
var kProductSearch      = '#product_search';
var kProductWebsiteUrl  = '#product_website_url';
var kProductImageUrl    = '#product_image_url';
var kProductIsHosted    = '#product_is_hosted';
var kProductUpload      = 'product_upload';
var kProductInput       = '#product_input';
var kProductImage       = '#product_image';
var kProductImageBox    = '#left';
var kProductImageClass  = 'photo';
var kImagesBox          = '#chooser';
var kImages             = '#results';

// Bing image search params
var kMediumImages       = 'Size:Medium';
var kLargeImages        = 'Size:Large';
var kImageCount         = 12;

// Image search states
var kSearchStateInactive    = 0;
var kSearchStateDone        = 3;

// State for all the images being displayed
var productHash  = new Array();
var settings     = undefined;


// Constructor logic
//
function NewProductViewController(uploadSettings) {
  
  var npvController     = this;

  this.offset           = 0;
  this.query            = '';
  this.searchState      = kSearchStateInactive;
  settings              = uploadSettings;
  this.uploader         = this.setupUploader(uploadSettings);

  $(kProductQuery).keypress(function(e) { 
                        return npvController.productQueryKeyPress(e); });

  $(kProductSearch).click(function() { return npvController.productSearchClicked();});

  $(kProductForm).submit(function() { return npvController.validateForm(); });

  this.scrollViewController                      = new ScrollViewController();
  this.scrollViewController.scrollEndedCallback  = function(){
                                                    npvController.scrollEnded();};
  this.scrollViewController.resizeEndedCallback  = function(){
                                                    npvController.resizeEnded();};
}

// Wrapper function for searching bing images to handle
// pagination and loading images with multiple filters
//
NewProductViewController.prototype.fetchImages = function() {

    if(this.searchState != kSearchStateInactive)
      return;

    this.searchState++;

    this.searchBingImages(this.query,kMediumImages,this.offset);
    this.searchBingImages(this.query,kLargeImages,this.offset);

    this.offset += kImageCount;
}

// Use the bing search api to find images for the given query and
// pagination information
//
NewProductViewController.prototype.searchBingImages = function(query,size,offset) {

  var url = [
              "http://api.bing.net/json.aspx?",
              "AppId=31862565CFBD51810ABE4AB2CEDCB80D52D33969&",
              "Version=2.2&",
              "Market=en-US&",
              "Query=" + encodeURIComponent(query) + "&",
              "Sources=Image+spell&",
              "Image.filters=" + size + "&",
              "Image.offset=" + offset + "&",
              "Image.count=" + kImageCount + "&",
              "JsonType=callback&",
              "JsonCallback=?"].join('');


  console.log(url);

  var npvController = this;

  $.ajax({
    type:       "GET",
    url:        url,
    dataType:   "jsonp",  
    success:    function(d){npvController.imagesLoaded(d);},
    error:      function(r,s,e){npvController.imagesError(r,s,e);}
  });
}

// Loads more items if the view isn't filled with items.
// In cases where the fixed number of items per page don't
// fill the screen
//
NewProductViewController.prototype.fillEmptyView = function() {
  if(!this.scrollViewController.isDocumentFillingWindow())
    this.fetchImages();
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Listeners on new product form elements
//-----------------------------------------------------------------------------

NewProductViewController.prototype.initiateProductSearch= function() {

  $(kImages).html('');
  $(kImagesBox).show();

  this.query        = $(kProductQuery).val();
  this.offset       = 0;
  this.searchState  = kSearchStateInactive;
  productHash       = new Array();

  this.fetchImages();
}

NewProductViewController.prototype.productQueryKeyPress = function(e) {
  if(e.keyCode == 13) {
    this.initiateProductSearch();
    return false;
  }
}

// Fired when the product search button is clicked
//
NewProductViewController.prototype.productSearchClicked = function(e) {
  this.initiateProductSearch();
  return false;
}

// Validate the product form and display errors before submissions
//
NewProductViewController.prototype.validateForm = function() {
  var valid = true;

  if($(kProductEndorsement).val().length < 1) {
    valid = false;
    console.log('improper endorsement');
  }
  else if($(kProductTitle).val().length < 1) {
    valid = false;
    console.log('improper title');
  }
    
  return valid;
}

// Fired when a product is selected from the search results
//
function productSelected(id) {
  var product = productHash[id];
  $(kProductInput).hide();
  $(kProductImageBox).addClass(kProductImageClass);
  $(kProductImage).html("<img id='left_photo' src='" + product.imageUrl + "' />");
  $(kProductIsHosted).val(0);
  $(kProductTitle).val($(kProductQuery).val());
  $(kProductWebsiteUrl).val(product.websiteUrl);
  $(kProductImageUrl).val(product.imageUrl);
  $(kImagesBox).hide();
 }


//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Ajax callbacks
//-----------------------------------------------------------------------------

//
NewProductViewController.prototype.imagesLoaded = function(data) {

    var query = data['SearchResponse']['Query']['SearchTerms'];

    if(query != this.query)
      return;

    var images = data['SearchResponse']['Image']['Results'];

    if(!images)
      return;
    

    for(var i=0;i<images.length;i++) {
      var product = new Product(
                          images[i]['Title'],
                          images[i]['Thumbnail']['Url'],
                          images[i]['MediaUrl'],
                          images[i]['Width'],
                          images[i]['Height'],
                          images[i]['Url']); 
      
      productHash[product.id] = product;

      $(kImages).append(product.imageSearchResultTag());
    }

    if(images.length == kImageCount && ++this.searchState == kSearchStateDone)
      this.searchState = kSearchStateInactive;
      
    //$('#' + kPaginationElementID + '').hide();

    this.fillEmptyView();
}

// Fired when there is an error fetching items
//
NewProductViewController.prototype.itemsError = function(request,status,error) {
}


//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// ScrollViewController callbacks
//-----------------------------------------------------------------------------

// Fired when the scrollbar has reached the end of the page
//
NewProductViewController.prototype.scrollEnded = function() {
  this.fetchImages();
}

// Fired when window resizing ends
//
NewProductViewController.prototype.resizeEnded = function() {
  this.fillEmptyView();
}


//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Upload callbacks and setup
//-----------------------------------------------------------------------------

// Setup an uploader at the previously designated element
//
NewProductViewController.prototype.setupUploader = function(settings) {

  return new SWFUpload({

          // Backend Settings
          upload_url: settings['server'],
          post_params: {"AWSAccessKeyId": settings['aws_id'],
                        "acl": "public-read",
                        "key": settings['key'] + "_${filename}",
                        "policy": settings['policy'],
                        "signature": settings['signature'],
                        "success_action_status":"201"},
          http_success : [201],

          // File Upload Settings
          file_post_name: 'file',
          file_size_limit : settings['max'],
          file_types : settings['extensions'],

          file_queued_handler: this.fileSelected,
          upload_progress_handler: this.uploadProgress,
          upload_error_handler: this.uploadError,
          upload_success_handler: this.uploadSuccess,
          upload_complete_handler: this.uploadComplete,

          // Button Settings
          button_placeholder_id : kProductUpload,
          button_image_url: "/images/transparent.gif",
          button_width: 350,
          button_height: 46,
          button_cursor: SWFUpload.CURSOR.HAND,
          button_window_mode: SWFUpload.WINDOW_MODE.TRANSPARENT,
          button_action : SWFUpload.BUTTON_ACTION.SELECT_FILE,
          
          // Flash Settings
          flash_url : "/swfs/swfupload.swf",
          debug: false
        });

}

// Called when the user selects a file
//
NewProductViewController.prototype.fileSelected = function(file) {
  this.startUpload(); 
}

// Called to indicate number of bytes uploaded to server
//
NewProductViewController.prototype.uploadProgress = function(file,bytesLoaded) {
    var percent = Math.ceil((bytesLoaded / file.size) * 100);
    console.log(percent + ' %');
}

// File finishes uploading -- not 100% reliable.
//
NewProductViewController.prototype.uploadSuccess = function(file,serverData) {
}

// Always called when a file finishes uploading
//
NewProductViewController.prototype.uploadComplete = function(file) {
  var filename = settings['key'] + '_' + file.name;
  console.log(filename);
  $(kProductImageUrl).val(filename);
  $(kProductIsHosted).val(1);
  $(kProductInput).hide();
  $(kProductImageBox).addClass(kProductImageClass);
  $(kProductImage).html("<img id='left_photo' src='" + settings['server'] + filename + "' />");
}

// Error handling during the uploading process
//
NewProductViewController.prototype.uploadError = function(errorCode,message) {
  console.log("upload error");

    switch (errorCode) {
    case SWFUpload.UPLOAD_ERROR.FILE_CANCELLED:
      break;
    case SWFUpload.UPLOAD_ERROR.UPLOAD_STOPPED:
    default:
      console.log("error message - " + message);
      break;
    }
}
