Denwen.Partials.Users.Search = Backbone.View.extend({

  //
  //
  initialize: function() {
    var self = this;

    this.query = "";
    this.keyUpTimer = null;
    this.users = new Denwen.Collections.Users();
    this.usersHash = new Array();

    this.el.keyup(function(e){self.keyup(e)});

    this.el.typeahead({
              items: 10,
              menu: '<ul class="search typeahead dropdown-menu border-box"></ul>',
              item: '<li class="txt s"><a href="#"></a></li>',
              updater: function(item) {
                var user = self.usersHash[item];
                window.location.href = "/" + user.get('handle') + "?src=search";
                return item;
              },
              highlighter: function(item) {
                var query = this.query.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, '\\$&');
                var user = self.usersHash[item];
                return "<img class='user-photo s rounded-3' src='" + user.get('square_image_url') + "'/>" + 
                        item.replace(new RegExp('(' + query + ')', 'ig'), function ($1, match) {
                          return '<strong>' + match + '</strong>';
                        });
              },
              sorter: function (items) {
                return items;
              },
              matcher: function(item){
                return 1;
                //return ~item.toLowerCase().replace(/[^\w]/g,'').
                //          indexOf(this.query.toLowerCase().
                //                        replace(/[^\w]/g,''));
              }});
  },

  // Apply the given data source to the users collection
  // and typeahead. Also initiates a new search.
  //
  applyDataSource: function(source,clean) {
    var self = this;

    this.users = source;
    this.usersHash = new Array();

    if(!clean)
      this.users.add(new Denwen.Models.User({
                          id: 0,
                          first_name: "Invite friends.",
                          last_name: "",
                          square_image_url: "/images/arrow-out.png",
                          handle: "invite"}));
    
    this.users.each(function(user){
      self.usersHash[user.fullName()] = user; 
    });

    this.el.data('typeahead').source = this.users.map(function(user){return user.fullName()});
    this.el.trigger('lookup');
  },

  // Handler for keystrokes on the input element.
  //
  keyup: function(e) {
    
    if(this.el.val() == this.query)
      return;

    this.query = this.el.val();

    this.applyDataSource(new Denwen.Collections.Users(),true);

    if(this.keyUpTimer != null)
      clearTimeout(this.keyUpTimer);
  
    var self = this;
    this.keyUpTimer = setTimeout(
                          function(){self.search(self.query);},
                          300);
    return true;
  },

  //
  //
  search: function(query) {
    if(query.length < 2)
      return;

    var self = this;

    this.users = new Denwen.Collections.Users();
    this.users.fetch({
          data      : {aspect: 'search',q: query},
          success   : function(collection){self.searched();},
          error     : function(collection,errors){}});
  },

  //
  //
  searched: function() {
    this.applyDataSource(this.users,false);
  }
});
