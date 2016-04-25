class ReceiptsController < ApplicationController
  respond_to :json

  def index
    if params[:lien_id]
      respond_with Lien.includes(:receipts).find(params[:lien_id]).receipts
    end
  end

  def create
    if params[:lien_id]
      data = params.permit(Receipt.column_names)
      lien = Lien.find(params[:lien_id])
      data[:check_amount] = data[:check_amount].to_f * 100
      data[:misc_principal] = data[:misc_principal].to_f * 100
      data[:subsequent] = Subsequent.find(params[:subsequent_id]) if params[:subsequent_id]
      data[:text_pad] = params[:note]
      receipt = Receipt.create!(data)
      receipt.lien = lien
      receipt.save!
      respond_with receipt
    end
  end

  # GET /api/lists/:list_id/todos/:id
  def show
    respond_with Receipt.find(params[:id])
  end

  # PUT/PATCH /api/lists/:list_id/todos/:id
  def update
    data = params.permit(Receipt.column_names)
    respond_with Receipt.find(params[:id]).update_attributes!(data)
  end
end
