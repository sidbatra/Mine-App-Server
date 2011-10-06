
function Product(title,imageUrl,imageWidth,imageHeight,websiteUrl) {
  this.title        = title;
  this.imageUrl     = imageUrl;
  this.imageWidth   = imageWidth;
  this.imageHeight  = imageHeight;
  this.websiteUrl   = websiteUrl;
}

Product.prototype.imageSearchResultTag = function() {
  return [
          "<a href='javascript:void(0)' ",
          "onclick='product_selected(1)'>",
          "<img height='200' ",
          "src='" + this.imageUrl + "' ",
          "/></a>"].join('');
}
