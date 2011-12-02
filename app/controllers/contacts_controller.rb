# Handle requests for the contacts resource
#
class ContactsController < ApplicationController
  before_filter :login_required

  # Fetch multiple contacts
  #
  def index
    @contacts = Contact.find_all_by_user_id(
                                    self.current_user.id,
                                    :order => :name)
  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json 
    end
  end

end
