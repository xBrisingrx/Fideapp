class ContactsController < ApplicationController
  before_action :set_contact, only: %i[ show edit update destroy modal_disable disable]

  def index
    @contacts = Contact.actives
    @client_id = params[:client_id]
  end

  def show
  end

  def new
    @contact = Contact.new(client_id: params[:client_id])
    @client = Client.find(params[:client_id])
    @title_modal = "Agregar contacto alternativo"
  end

  def edit
    @title_modal = "Agregar contacto alternativo"
  end

  def create
    @contact = Contact.new(contact_params)

    respond_to do |format|
      if @contact.save
        format.json { render json: {status: 'success', msg: 'Contacto registado', contact: @contact } , status: :created }
        format.html { redirect_to contact_url(@contact), notice: "Contact was successfully created." }
      else
        format.json { render json: @contact.errors, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @contact.update(contact_params)
        format.html { redirect_to contact_url(@contact), notice: "Contact was successfully updated." }
        format.json { render :show, status: :ok, location: @contact }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @contact.destroy

    respond_to do |format|
      format.html { redirect_to contacts_url, notice: "Contact was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def modal_disable
    
  end

  def disable
    contact_id = @contact.id
    @contact.destroy
    render json: { status: "success", msg: "Contacto eliminado", contact_id: contact_id }, status: :ok
  end

  private
    def set_contact
      @contact = Contact.find(params[:id])
      @client = Client.find(params[:client_id])
    end

    def contact_params
      params.require(:contact).permit(:name, :relationship, :client_id, :phone, :active)
    end
end
