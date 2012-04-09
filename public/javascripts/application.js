// Setup the namespace for the js MVc setup
//
var Denwen = {
  Models      : {},
  Views       : { Users : {}, Products : {}, 
                  Invites : {}, Welcome : {}, 
                  Admin : {Suggestions : {},Stores : {}}, 
                  Settings : {}, Feed : {}},
  Partials    : { Users : {}, Products : {}, 
                  Facebook : {}, Stores : {}, Invites : {}, 
                  Common : {}, Followings : {}, 
                  Comments : {}, Likes :{}, Feed:{},
                  Admin : {Suggestions : {},Stores : {}}},
  Collections : {},
  Callbacks   : {}
};



// Extend Backbone.Model to add associations
//
 _.extend(Backbone.Model.prototype, Backbone.Events, {

  // Create a model to model association by
  // extracting an attribute stored as a hash
  // and converting it into the desired model
  //
  createAssociation: function(key,model) {
    var association = new model(this.get(key));
    this.unset(key,{silent:true});

    var attributes = new Array();
    attributes[key] = association;
    this.set(attributes,{silent:true});
  },
  
  // Associate searches for the existence
  // of the key to be bound to a model. If found
  // it instantly creates the binding else it
  // tracks a change event to see when that key
  // gets setup to create a binding
  //
  associate: function(key,model) {

    var json = this.get(key);

    if(json != null && json != undefined) {
      this.createAssociation(key,model);
    }
    else {
      var self = this;
      this.bind('change',function() { 
        if(self.hasChanged(key))
          self.createAssociation(key,model);
      });
    }
  }

 });
