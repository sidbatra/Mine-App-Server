// ProductShowViewController provides a javascript interface for
// displaying a product
//
function ProductShowViewController(product_id) {
  var psvController     = this;
  this.product_id       = product_id;
}

// Share the product to social networks
//
ProductShowViewController.prototype.share = function() {
  $.ajax({
    type:       "POST",
    url:        "/share.js?product_id=" + this.product_id,
    success:    function(d){trace(d);},
    error:      function(r,s,e){trace(r + ' ' + s + ' ' + e);}
    });
}
