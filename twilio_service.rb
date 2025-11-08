class TwilioService
  def initialize
    @client = Twilio::REST::Client.new(
      ENV['TWILIO_ACCOUNT_SID'],
      ENV['TWILIO_AUTH_TOKEN']
    )
  end
  
  def make_call(contact_id, script_message = nil)
    contact = Contact.find(contact_id)
    message = script_message || "Hello, this is an automated call from Autodialer."
    
    # Create TwiML URL for the call
    twiml_url = "#{ENV['APP_URL']}/twilio/voice?message=#{CGI.escape(message)}"
    
    call = @client.calls.create(
      from: ENV['TWILIO_PHONE_NUMBER'],
      to: contact.phone_number,
      url: twiml_url,
      status_callback: "#{ENV['APP_URL']}/twilio/status_callback"
    )
    
    # Create call log
    CallLog.create(
      contact: contact,
      call_sid: call.sid,
      status: call.status,
      started_at: Time.now
    )
    
    contact.update(status: 'calling', last_called_at: Time.now)
    
    { success: true, call_sid: call.sid }
  rescue => e
    contact.update(status: 'failed') if contact
    CallLog.create(
      contact: contact,
      status: 'failed',
      error_message: e.message,
      started_at: Time.now
    )
    { success: false, error: e.message }
  end
  
  def get_call_status(call_sid)
    call = @client.calls(call_sid).fetch
    {
      status: call.status,
      duration: call.duration,
      direction: call.direction
    }
  rescue => e
    { error: e.message }
  end
end
