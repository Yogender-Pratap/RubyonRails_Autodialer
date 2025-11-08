class ContactsController < ApplicationController
  def index
    @contacts = Contact.order(created_at: :desc)
    @stats = {
      total: Contact.count,
      pending: Contact.where(status: 'pending').count,
      calling: Contact.where(status: 'calling').count,
      completed: Contact.where(status: 'completed').count,
      failed: Contact.where(status: 'failed').count
    }
  end
  
  def new
    @contact = Contact.new
  end
  
  def create
    @contact = Contact.new(contact_params)
    if @contact.save
      redirect_to contacts_path, notice: 'Contact added successfully'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def bulk_import
    if params[:text_numbers].present?
      count = Contact.import_from_text(params[:text_numbers])
      redirect_to contacts_path, notice: "#{count} numbers imported successfully"
    elsif params[:csv_file].present?
      count = Contact.import_from_csv(params[:csv_file])
      redirect_to contacts_path, notice: "#{count} numbers imported from CSV"
    else
      redirect_to contacts_path, alert: 'Please provide numbers or CSV file'
    end
  end
  
  def destroy
    @contact = Contact.find(params[:id])
    @contact.destroy
    redirect_to contacts_path, notice: 'Contact deleted'
  end
  
  def clear_all
    Contact.destroy_all
    redirect_to contacts_path, notice: 'All contacts cleared'
  end
  
  private
  
  def contact_params
    params.require(:contact).permit(:phone_number, :name, :notes)
  end
end
