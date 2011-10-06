
function Product(title,imageUrl,imageWidth,imageHeight,websiteUrl) {
  this.title        = title;
  this.imageUrl     = imageUrl;
  this.imageWidth   = imageWidth;
  this.imageHeight  = imageHeight;
  this.websiteUrl   = websiteUrl;
  this.id           = this.imageUrl;
}

Product.prototype.imageSearchResultTag = function() {
  return [
          "<a href='javascript:void(0)' ",
          "onclick=\"product_selected('" + this.id + "')\">",
          "<img height='200' ",
          "src='" + this.imageUrl + "' ",
          "/></a>"].join('');
}
