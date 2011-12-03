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
      fb_friends        = self.current_user.fb_friends

      @contacts         = fb_friends.map{|f| 
                              Contact.from_fb_friend(self.current_user.id,f)}
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
