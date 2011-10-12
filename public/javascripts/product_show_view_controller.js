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

  mpq.track("Save and Share it!");
}

//Setup analytics for logged out state
//
ProductShowViewController.prototype.setupLoggedOutAnalytics = function() {
  mpq.track_links($("#action_link"),"FB Connect");
}

//Setup analytics for logged in state
//
ProductShowViewController.prototype.setupLoggedInAnalytics = function() {
  mpq.track_links($("#action_link"),"Share your own item");
}

//Setup analytics for post creation page
//
ProductShowViewController.prototype.setupPostCreationAnalytics = function() { 
  mpq.track_links($("#action_link"),"Done! Post Another");
}
