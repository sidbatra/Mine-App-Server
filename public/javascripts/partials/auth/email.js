Denwen.Partials.Auth.Email = Backbone.View.extend({

  initialize: function() {
    var self = this;

    this.googleEl = this.options.googleEl;
    this.yahooEl = this.options.yahooEl;
    this.hotmailEl = this.options.hotmailEl;
    this.successURL = this.options.successURL;

    this.loadClass = 'load';

    this.googleAuth = new Denwen.Partials.Auth.Google();

    this.googleAuth.bind(
      Denwen.Partials.Auth.Google.Callback.AuthAccepted,
      this.googleAuthAccepted,
      this);

    this.googleAuth.bind(
      Denwen.Partials.Auth.Google.Callback.AuthRejected,
      this.googleAuthRejected,
      this);


    this.yahooAuth = new Denwen.Partials.Auth.Yahoo();

    this.yahooAuth.bind(
      Denwen.Partials.Auth.Yahoo.Callback.AuthAccepted,
      this.yahooAuthAccepted,
      this);

    this.yahooAuth.bind(
      Denwen.Partials.Auth.Yahoo.Callback.AuthRejected,
      this.yahooAuthRejected,
      this);
                      

    this.hotmailAuth = new Denwen.Partials.Auth.Hotmail({el: this.el});

    this.hotmailAuth.bind(
      Denwen.Partials.Auth.Hotmail.Callback.AuthAccepted,
      this.hotmailAuthAccepted,
      this);

    this.hotmailAuth.bind(
      Denwen.Partials.Auth.Hotmail.Callback.AuthRejected,
      this.hotmailAuthRejected,
      this);

    $(this.googleEl).click(function(){self.googleClicked();});
    $(this.yahooEl).click(function(){self.yahooClicked();});
    $(this.hotmailEl).click(function(){self.hotmailClicked();});
  },

  googleClicked: function() {
    $(this.googleEl).addClass(this.loadClass);
    this.googleAuth.showAuthDialog();

    Denwen.Track.action("Google Connect Initiated");
  },

  yahooClicked: function() {
    $(this.yahooEl).addClass(this.loadClass);
    this.yahooAuth.showAuthDialog();

    Denwen.Track.action("Yahoo Connect Initiated");
  },

  hotmailClicked: function() {
    this.hotmailAuth.showAuthDialog();

    Denwen.Track.action("Hotmail Connect Initiated");
  },

  authAccepted: function() {
    window.location.href = this.successURL;
  },

  googleAuthAccepted: function() {
    this.authAccepted();
  },

  googleAuthRejected: function() {
    $(this.googleEl).removeClass(this.loadClass);
    Denwen.Drawer.error("Google connect is required to import your purchases.");
  },

  yahooAuthAccepted: function() {
    this.authAccepted();
  },

  yahooAuthRejected: function() {
    $(this.yahooEl).removeClass(this.loadClass);
    Denwen.Drawer.error("Yahoo connect is required to import your purchases.");
  },

  hotmailAuthAccepted: function() {
    $(this.hotmailEl).addClass(this.loadClass);
    this.authAccepted();
  },

  hotmailAuthRejected: function() {
  }

});
