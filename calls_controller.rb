class CallsController < ApplicationController
  def index
    @call_logs = CallLog.includes(:contact).order(created_at: :desc).limit(100)
  end
  
  def create
    contact = Contact.find(params[:contact_id])
    service = TwilioService.new
    result = service.make_call(contact.id, params[:message])
    
    if result[:success]
      redirect_to contacts_path, notice: 'Call initiated successfully'
    else
      redirect_to contacts_path, alert: "Call failed: #{result[:error]}"
    end
  end
  
  def bulk_call
    contact_ids = Contact.where(status: 'pending').pluck(:id)
    
    if contact_ids.empty?
      redirect_to contacts_path, alert: 'No pending contacts to call'
      return
    end
    
    service = TwilioService.new
    delay = (params[:delay] || 2).to_i
    message = params[:message]
    
    # Start calling in background
    Thread.new do
      contact_ids.each do |contact_id|
        service.make_call(contact_id, message)
        sleep(delay)
      end
    end
    
    redirect_to contacts_path, notice: "Bulk calling #{contact_ids.count} contacts..."
  end
  
  def ai_command
    command = params[:command].downcase
    
    # Simple AI command parser
    if command.match(/call (\+?\d+)/)
      phone_number = command.match(/call (\+?\d+)/)[1]
      contact = Contact.find_or_create_by(phone_number: phone_number)
      service = TwilioService.new
      result = service.make_call(contact.id, params[:message])
      
      render json: { success: true, message: "Calling #{phone_number}..." }
    elsif command.match(/call all/)
      contact_ids = Contact.where(status: 'pending').pluck(:id)
      
      service = TwilioService.new
      Thread.new do
        contact_ids.each do |contact_id|
          service.make_call(contact_id)
          sleep(2)
        end
      end
      
      render json: { success: true, message: "Calling all pending contacts..." }
    else
      render json: { success: false, message: "Command not recognized. Try 'call +15005550006' or 'call all'" }
    end
  end
end
