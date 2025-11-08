class TwilioController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def voice
    message = params[:message] || "Hello, this is an automated call from Autodialer."
    
    response = Twilio::TwiML::VoiceResponse.new do |r|
      r.say(
        message: message,
        voice: 'Polly.Joanna',
        language: 'en-US'
      )
    end
    
    render xml: response.to_s
  end
  
  def status_callback
    call_log = CallLog.find_by(call_sid: params[:CallSid])
    
    if call_log
      call_log.update(
        status: params[:CallStatus],
        duration: params[:CallDuration],
        ended_at: Time.now
      )
      
      call_log.contact.update(status: params[:CallStatus])
    end
    
    head :ok
  end
end
