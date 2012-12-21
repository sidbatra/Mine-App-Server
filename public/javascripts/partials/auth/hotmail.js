Denwen.Partials.Auth.Hotmail = Backbone.View.extend({

  initialize: function() {
    var self = this;

    this.loadClass = "load";
    this.emailEl = "#hotmail_email";
    this.passwordEl = "#hotmail_password";
    this.submitEl = "#hotmail_submit_button";
    this.modalEl = "#hotmail_connect";

    $(this.submitEl).click(function(){self.submitClicked();});
    $(this.passwordEl).keypress(function(e){return self.passwordKeystroke(e);});
  },

  showAuthDialog: function() {
  },

  passwordKeystroke: function(e) {
    if(e.keyCode == 13)
      this.submitClicked();
  },

  submitClicked: function() {
    var email = $(this.emailEl).val();
    var password = $(this.passwordEl).val();

    if(!email.length || !password.length)
      return;

    var self = this;

    $(this.submitEl).addClass(this.loadClass);

    $.ajax({
      type: 'post',
      url: "/hotmail.json",
      data: {email: email, password: password},
      success: function(data) {self.fetched(data);},
      error: function() {self.fetched(0);}});
  },

  fetched: function(data) {
    $(this.submitEl).removeClass(this.loadClass);

    if(data) {
      $(this.modalEl).modal('hide');
 
      Denwen.Track.action("Hotmail Authorization Accepted");
      this.trigger(Denwen.Partials.Auth.Hotmail.Callback.AuthAccepted);
    }
    else {
      Denwen.Track.action("Hotmail Authorization Rejected");
      this.trigger(Denwen.Partials.Auth.Hotmail.Callback.AuthRejected);
    }
  }

});

Denwen.Partials.Auth.Hotmail.Callback = {
  AuthAccepted: 'hmAuthAccepted',
  AuthRejected: 'hmAuthRejected'
}


