Denwen.Partials.Invites.Email = Backbone.View.extend({

  // Constructor logic
  //
  initialize: function() {
    var self = this;

    this.posting = false;
    this.postEl = "#create_email_invite";
    this.emailEls = $('input.email');
    this.messageEl = "#email_message";

    this.setupPlaceholders();

    $(this.postEl).click(function(){self.post();});
  },

  setupPlaceholders: function() {
    _.each(this.emailEls,function(email){
      $('#' + email.id).placeholder();
    });

    $(this.messageEl).placeholder();
  },

  startLoading: function() {
    $(this.postEl).addClass('load');
  },

  stopLoading: function() {
    $(this.postEl).removeClass('load');
  },

  // Test if the email form passes validation.
  //
  validate: function() {
    var valid = false;

    _.each(this.emailEls,function(email){
      if(email.value.length && email.value != $('#' + email.id).attr('placeholder'))
        valid = true;
    });

    return valid;
  },

  post: function() {
    if(this.posting || !this.validate())
      return;

    var self = this;

    this.posting = true;
    this.startLoading();

    var invites = [];

    _.each(this.emailEls,function(email){
      if(email.value.length && email.value != $('#' + email.id).attr('placeholder')) {
        invites.push({
          recipient_id: email.value,
          platform: Denwen.InvitePlatform.Email});
      }
    });

    var invite = new Denwen.Models.Invite();
    invite.save({
      invites: invites,
      message: $(this.messageEl).val() != $(this.messageEl).attr('placeholder') ?
                $(this.messageEl).val() :
                ""},{
      success: function(model) {self.inviteCreated();},
      error: function(model,error) {self.inviteFailed();}});
  },

  inviteCreated: function() {
    this.posting = false;
    this.stopLoading();

    Denwen.Track.action("Invite Created",{"Source":"email"});

    Denwen.Drawer.success("Invite successfully sent.");

    _.each(this.emailEls,function(email){
      email.value = "";
    });

    $(this.messageEl).val('');

    this.setupPlaceholders();
  },

  inviteFailed: function() {
    this.posting = false;
    this.stopLoading();

    Denwen.Drawer.error("Sorry, there was an error sending your invite. Please try again.");
  }

});
