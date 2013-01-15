class SmsController < ApplicationController
  layout nil

  # Handle post requests for sending text messages
  #
  def create
    to = params[:to]

    unless to
      raise IOError, "Incorrect params for sending text message" 
    end

    @client = Twilio::REST::Client.new(
                CONFIG[:twilio_account_sid],
                CONFIG[:twilio_auth_token])

    @account = @client.account
    @message = @account.sms.messages.create({
                  :from   => CONFIG[:twilio_phone_number],
                  :to     => to,
                  :body   => "Happy Mining! #{CONFIG[:ios_app_link]}"}) 

  rescue => ex
    handle_exception(ex)
  ensure
    respond_to do |format|
      format.json
    end
  end

end
