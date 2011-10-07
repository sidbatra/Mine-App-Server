// Product provides an interface for storing product data
// and view helpers
//

function Product(title,imageUrl,imageWidth,imageHeight,websiteUrl) {
  this.title        = title;
  this.imageUrl     = imageUrl;
  this.imageWidth   = imageWidth;
  this.imageHeight  = imageHeight;
  this.websiteUrl   = websiteUrl;
  this.id           = this.imageUrl;

  //var link = document.createElement('a');
  //link.setAttribute('href','javascript:void(0)');
  //link.setAttribute('onclick',"alert('in')");
  //link.innerHTML = "<img height='200' src='" + this.imageUrl + "' />";
}

// Generate an image tag that activates product selection javascript
// on click
//
Product.prototype.imageSearchResultTag = function() {
  return [
          "<div class='photo_choice_cell' ",
          "onclick=\"productSelected('" + this.id + "')\">",
          "<img class='photo_choice' ",
          "src='" + this.imageUrl + "' ",
          "/></div>"].join('');

          //"<a href='javascript:void(0)' ",
          //"onclick=\"productSelected('" + this.id + "')\">",
          //"<img height='200' ",
          //"src='" + this.imageUrl + "' ",
          //"/></a>"].join('');
}
