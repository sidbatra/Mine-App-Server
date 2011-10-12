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
var kProductCancel      = '#product_cancel';
var kProductSelection   = '#product_selection';
var kImagesBox          = '#chooser';
var kImagesBoxClose     = '#chooser_closebox'
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
  
  var npvController       = this;

  this.empty              = 0;
  this.offset             = 0;
  this.query              = '';
  this.searchState        = kSearchStateInactive;
  settings                = uploadSettings;
  this.uploader           = this.setupUploader(uploadSettings);
  this.defProdTitle       = $(kProductTitle).val();
  this.defProdEndorsement = $(kProductEndorsement).val();


  make_conditional_field(
    kProductQuery,
    $(kProductQuery).val(),
    $(kProductQuery).css('color'),
    '#333333');

  make_conditional_field(
    kProductTitle,
    this.defProdTitle,
    $(kProductTitle).css('color'),
    '#333333');

  restrictFieldSize($(kProductTitle),80,'charsremain');

  make_conditional_field(
    kProductEndorsement,
    this.defProdEndorsement,
    $(kProductEndorsement).css('color'),
    '#333333');

  restrictFieldSize($(kProductEndorsement),120,'charsremain');

  // Clear shared items on escape
  $('html').keydown(function(e) {
    npvController.globalKeystroke(e);
  });

  $(kProductQuery).keypress(function(e) { 
                        return npvController.productQueryKeyPress(e); });

  $(kProductSearch).click(function() { return npvController.productSearchClicked();});

  $(kProductCancel).click(function() { return npvController.productCancelClicked();});

  $(kProductForm).submit(function() { return npvController.validateForm(); });

  $(kImagesBoxClose).click(function() { npvController.closeImagesBox(); });

  /*$(kProductTitle).blur(function() { mpq.track("Item Name: " +
                                                $(kProductTitle).val());});

  $(kProductEndorsement).blur(function() { mpq.track("Item Endoresement: " +
                                                $(kProductEndorsement).val());});*/


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

    if(this.searchState != kSearchStateInactive || 
            !this.isSearchActive())
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


  trace(url);

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

// Returns whether search is currently active
//
NewProductViewController.prototype.isSearchActive = function() {
  return $(kImagesBox).is(":visible");
}


//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Listeners on new product form elements
//-----------------------------------------------------------------------------

NewProductViewController.prototype.initiateProductSearch= function() {

  if($(kProductQuery).val() == '' || 
        $(kProductQuery).val() == 'Search for an item by name...')
    return;

  $(kImages).html('');
  $(kImagesBox).show();

  this.empty        = 0;
  this.query        = $(kProductQuery).val();
  this.offset       = 0;
  this.searchState  = kSearchStateInactive;
  productHash       = new Array();

  this.fetchImages();
  //mpq.track("Searched for: " + this.query);
  _kmq.push(['record', 'Searched for: ' + this.query]);
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

  if($(kProductImageUrl).val().length < 1) {
    valid = false;
    alert('image');
  }
  else if($(kProductTitle).val().length < 1 || 
      $(kProductTitle).val() == this.defProdTitle) {
    valid = false;
    alert('improper title');
  }
  else if($(kProductEndorsement).val().length < 1 || 
      $(kProductEndorsement).val() == this.defProdEndorsement) {
    valid = false;
    alert('improper endorsement');
  }
    
  return valid;
}

NewProductViewController.prototype.globalKeystroke = function(e) {
  if(e.which == 27 && this.isSearchActive())
    this.closeImagesBox();
}

// Hide the search box
//
NewProductViewController.prototype.closeImagesBox = function() {
  $(kImagesBox).hide();
}

// Fired when the product selection is cancelled
//
NewProductViewController.prototype.productCancelClicked = function() {
  $(kProductImageBox).removeClass(kProductImageClass);
  $(kProductInput).show();
  $(kProductSelection).hide();

  //mpq.track("product cancelled");
  _kmq.push(['record', 'product cancel']);
}

// Fired when a product is selected from the search results
//
function productSelected(id) {
  var product = productHash[id];
  $(kProductSelection).show();
  $(kProductInput).hide();
  $(kProductImageBox).addClass(kProductImageClass);
  $(kProductImage).html("<img id='left_photo' src='" + product.imageUrl + "' />");
  $(kProductIsHosted).val(0);
  $(kProductTitle).val($(kProductQuery).val().toProperCase());
  $(kProductTitle).focus();
  $(kProductWebsiteUrl).val(product.websiteUrl);
  $(kProductImageUrl).val(product.imageUrl);
  $(kImagesBox).hide();

  //mpq.track("product selected");
  _kmq.push(['record', 'product select']);
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
    var offset = data['SearchResponse']['Image']['Offset'];

    if(offset == 0 && !images)
      this.empty++;

    if(this.empty == 2) {
      this.closeImagesBox();
      alert('Sorry nothing gounf');
    }
    
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
          button_image_url: '/images/transparent.gif',
          button_width: 350,
          button_height: 46,
          button_cursor: SWFUpload.CURSOR.HAND,
          button_window_mode: SWFUpload.WINDOW_MODE.TRANSPARENT,
          button_action : SWFUpload.BUTTON_ACTION.SELECT_FILE,
          
          // Flash Settings
          flash_url : '/swfs/swfupload.swf',
          debug: false
        });

}

// Called when the user selects a file
//
NewProductViewController.prototype.fileSelected = function(file) {
  this.startUpload(); 
  //mpq.track("File Selected for upload");
  _kmq.push(['record', 'File Select for upload']);
}

// Called to indicate number of bytes uploaded to server
//
NewProductViewController.prototype.uploadProgress = function(file,bytesLoaded) {
    var percent = Math.ceil((bytesLoaded / file.size) * 100);
    trace(percent + ' %');
}

// File finishes uploading -- not 100% reliable.
//
NewProductViewController.prototype.uploadSuccess = function(file,serverData) {
}

// Always called when a file finishes uploading
//
NewProductViewController.prototype.uploadComplete = function(file) {
  var filename = settings['key'] + '_' + file.name;
  trace(filename);
  $(kProductSelection).show();
  $(kProductInput).hide();
  $(kProductImageUrl).val(filename);
  $(kProductIsHosted).val(1);
  $(kProductImageBox).addClass(kProductImageClass);
  $(kProductImage).html("<img id='left_photo' src='" + settings['server'] + filename + "' />");
  $(kProductTitle).focus();
}

// Error handling during the uploading process
//
NewProductViewController.prototype.uploadError = function(errorCode,message) {
  trace("upload error");

    switch (errorCode) {
    case SWFUpload.UPLOAD_ERROR.FILE_CANCELLED:
      break;
    case SWFUpload.UPLOAD_ERROR.UPLOAD_STOPPED:
    default:
      trace("error message - " + message);
      break;
    }
}


//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Analytics 
//-----------------------------------------------------------------------------

//Setup analytics for creation page
//
NewProductViewController.prototype.setupPreCreationAnalytics = function(identifier) {
  //mpq.name_tag(username);
  //mpq.track_forms($("#new_product"),"Save and Share it!");

  _kmq.push(['identify', identifier]);
}

