class CreditNotesController < ApplicationController
  before_action :set_credit_note, only: %i[ show edit update destroy ]

  # GET /credit_notes or /credit_notes.json
  def index
    @credit_notes = CreditNote.where(sale_id: params[:sale_id])
  end

  # GET /credit_notes/1 or /credit_notes/1.json
  def show
  end

  # GET /credit_notes/new
  def new
    @title_modal = "Nota de credito"
    sale_id = Payment.find(params[:payment_id]).sale.id
    @credit_note = CreditNote.new( payment_id: params[:payment_id], sale_id: sale_id )
  end

  # GET /credit_notes/1/edit
  def edit
  end

  # POST /credit_notes or /credit_notes.json
  def create
    credit_note = CreditNote.new(credit_note_params)
    credit_note.user = current_user

    respond_to do |format|
      if credit_note.save
        format.json { render json: { status: 'success', msg: 'Pago eliminado' }, status: :created }
        format.html { redirect_to credit_note_url(credit_note), notice: "Credit note was successfully created." }
      else
        format.json { render json: credit_note.errors, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /credit_notes/1 or /credit_notes/1.json
  def update
    respond_to do |format|
      if @credit_note.update(credit_note_params)
        format.html { redirect_to credit_note_url(@credit_note), notice: "Credit note was successfully updated." }
        format.json { render :show, status: :ok, location: @credit_note }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @credit_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /credit_notes/1 or /credit_notes/1.json
  def destroy
    @credit_note.destroy

    respond_to do |format|
      format.html { redirect_to credit_notes_url, notice: "Credit note was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_credit_note
      @credit_note = CreditNote.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def credit_note_params
      params.require(:credit_note).permit(:description, :fee_payment_id,:payment_id, :sale_id, :user_id, :date ,:active)
    end
end
