// NewProductViewController provides a javascript interface for
// creating a new product

// UI elements 
var kProductForm        = '#new_product';
var kProductTitle       = '#product_title';
var kProductEndorsement = '#product_endorsement';
var kProductQuery       = '#product_query';
var kProductWebsiteURL  = '#product_website_url';
var kProductImageURL    = '#product_image_url';
var kImagesBox          = '#results';

// Bing image search params
var kMediumImages       = 'Size:Medium';
var kLargeImages        = 'Size:Large';
var kImageCount         = 10;

// Image search states
var kSearchStateInactive    = 0;
var kSearchStateDone        = 3;


// Constructor logic
//
function NewProductViewController() {
  
  var npvController     = this;

  this.offset           = 0;
  this.query            = '';
  this.searchState     = kSearchStateInactive;

  $(kProductQuery).keypress(function(e) { 
                        return npvController.productQueryKeyPress(e); });

  this.scrollViewController                      = new ScrollViewController();
  this.scrollViewController.scrollEndedCallback  = function(){
                                                    npvController.scrollEnded();
                                                    };
  this.scrollViewController.resizeEndedCallback  = function(){
                                                    npvController.resizeEnded();
                                                    };
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

NewProductViewController.prototype.productQueryKeyPress = function(e) {
  if(e.keyCode == 13) {
    $(kImagesBox).html('');

    this.query        = $(kProductQuery).val();
    this.offset       = 0;
    this.searchState  = kSearchStateInactive;

    this.fetchImages();

    return false;
  }
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
      var image = images[i];
      //$('#results').append("<h2>" + image['Title'] + "</h2>");
      //$('#results').append("<h4>" + image['Width'] + 'x' + image['Height'] + "</h4>");
      //$('#results').append("<a href='" + image['MediaUrl'] + "'><img height='100' src='" + image['MediaUrl'] + "' /></a>");
      //$(kImagesBox).append("<a href='#' onclick='product_selected(1)'><img src='" + image['Thumbnail']['Url'] + "' /></a>");
      $(kImagesBox).append("<a href='#' onclick='product_selected(1)'><img height='200' src='" + image['MediaUrl'] + "' /></a>");
    }

    if(images.length == kImageCount && ++this.searchState == kSearchStateDone)
      this.searchState = kSearchStateInactive;
      
    //  $('#' + kPaginationElementID + '').hide();

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

