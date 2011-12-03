# Handle requests for the contacts resource
#
class ContactsController < ApplicationController
  before_filter :login_required

  # Fetch multiple contacts
  #
  def index
    if self.current_user.has_contacts_mined
      @contacts = Contact.find_all_by_user_id(
                                      self.current_user.id,
                                      :order => :name)
    else
      @contacts         = []
      fb_user           = FbGraph::User.new('me', 
                                :access_token => self.current_user.access_token)

      fb_friends        = fb_user.friends

      fb_friends.each do |fb_friend|
        @contacts << Contact.new({
                          :user_id        => self.current_user.id,
                          :third_party_id => fb_friend.identifier,
                          :name           => fb_friend.name})

        @contacts.sort!{|x,y| x.name <=> y.name}
      end
    end
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end

end
