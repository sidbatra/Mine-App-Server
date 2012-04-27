class ContactsController < ApplicationController
  before_filter :login_required

  # List contacts for the current user.
  #
  # If the user's contacts have been previously
  # mined they're fetched from the db otherwise
  # the user's fb token is used to fetch their
  # friends.
  #
  def index
    if self.current_user.has_contacts_mined
      @contacts = Contact.
                    select(:id,:third_party_id,:name).
                    by_name.
                    for_user(self.current_user.id)
    else
      @contacts  = []
      fb_friends = self.current_user.fb_friends

      @contacts = fb_friends.map do |fb_friend| 
                    Contact.new({
                      :user_id => self.current_user.id,
                      :third_party_id => fb_friend.identifier,
                      :name => fb_friend.name})
                  end
      @contacts.sort!{|x,y| x.name <=> y.name}
    end
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end

end
