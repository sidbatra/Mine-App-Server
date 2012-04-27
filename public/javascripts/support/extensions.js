
// Add proper case functionality to strings
//
String.prototype.toProperCase = function () {
    return this.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
};

// Capitalize the first character of a string
//
String.prototype.capitalize = function() {
  return this.charAt(0).toUpperCase() + this.slice(1);
};

// Parse a string that contains an iso8601 timestamp. 
// Eg - "2012-04-05T18:20:17-07:00".
// Found deep inside the source code of timeAgo.
// https://github.com/rmm5t/jquery-timeago
//
// returns - Date. Date object parsed from the string.
//
String.prototype.toDate = function() {
  var s = $.trim(this);
  s = s.replace(/\.\d\d\d+/,""); // remove milliseconds
  s = s.replace(/-/,"/").replace(/-/,"/");
  s = s.replace(/T/," ").replace(/Z/," UTC");
  s = s.replace(/([\+\-]\d\d)\:?(\d\d)/," $1$2"); // -04:00 -> -0400
  return new Date(s);
};

var uncheckedkeycodes=/(8)|(13)|(16)|(17)|(18)/;  //keycodes that are not checked, even when limit has been reached.

function restrictFieldSize($fields, optsize, optoutputdiv){
  var $=jQuery
  $fields.each(function(i){
    var $field=$(this)
    $field.data('maxsize', optsize || parseInt($field.attr('data-maxsize'))) //max character limit
    var statusdivid=optoutputdiv || $field.attr('data-output') //id of DIV to output status
    $field.data('$statusdiv', $('#'+statusdivid).length==1? $('#'+statusdivid) : null)
    $field.unbind('keypress.restrict').bind('keypress.restrict', function(e){
      restrictFieldSize.restrict($field, e)
    })
    $field.unbind('keyup.show').bind('keyup.show', function(e){
      restrictFieldSize.showlimit($field)
    })
    restrictFieldSize.showlimit($field) //show status to start
  })
}

restrictFieldSize.restrict=function($field, e){
  var keyunicode=e.charCode || e.keyCode
  if (!uncheckedkeycodes.test(keyunicode)){
    if ($field.val().length >= $field.data('maxsize')){ //if characters entered exceed allowed
      if (e.preventDefault)
        e.preventDefault()
      return false
    }
  }
}

restrictFieldSize.showlimit=function($field){
  if ($field.val().length > $field.data('maxsize')){
    var trimmedtext=$field.val().substring(0, $field.data('maxsize'))
    $field.val(trimmedtext)
  }
  if ($field.data('$statusdiv')){
    $field.data('$statusdiv').css('color', '').html($field.val().length)
    var pctremaining=($field.data('maxsize')-$field.val().length)/$field.data('maxsize')*100 //calculate chars remaining in terms of percentage
    for (var i=0; i<thresholdcolors.length; i++){
      if (pctremaining<=parseInt(thresholdcolors[i][0])){
        $field.data('$statusdiv').css('color', thresholdcolors[i][1])
        break
      }
    }
  }
}

// Wrapper around set selection Range 
//
$.fn.selectRange = function(start, end) {
    return this.each(function() {
        if (this.setSelectionRange) {
            this.focus();
            this.setSelectionRange(start, end);
        } else if (this.createTextRange) {
            var range = this.createTextRange();
            range.collapse(true);
            range.moveEnd('character', end);
            range.moveStart('character', start);
            range.select();
        }
    });
};

// Test if the browser supports HTML5 placeholders.
//
jQuery.support.placeholder = (function(){
    var i = document.createElement('input');
    return ('placeholder' in i) && !$.browser.mozilla;
})();


// Cross browser placeholder functionality for input fields.
// Input field must have a placeholder attribute.
//
$.fn.placeholder = function() {
  
  if($.support.placeholder)
    return;

  var placeholder = this.attr('placeholder');
  var placeholderColor = "#999999";
  var textColor = this.css('color');

  if(this.val() == '') {
    this.val(placeholder);
    this.css('color',placeholderColor);
  }
  else {
    this.css('color',textColor);
  }

  this.focus(function() { 
    if(this.value == placeholder)
      this.value = '';

    this.style.color = textColor;
  });

  this.blur(function() {
    if(this.value == '') { 
      this.value = placeholder;
      this.style.color = placeholderColor;
    }
  });
}
