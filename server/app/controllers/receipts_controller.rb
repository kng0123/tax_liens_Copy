class ReceiptsController < ApplicationController
  respond_to :json

  # GET /api/lists/:list_id/todos
  def index
    if params[:lien_id]
      respond_with Lien.includes(:receipts).find(params[:lien_id]).receipts
    end
  end

  # POST /api/lists/:list_id/todos
  def create
    if params[:lien_id]
      lien = Lien.find(params[:lien_id])
      receipt = Receipt.create!(params)
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
    data = params.permit(Lien.column_names)
    respond_with Receipt.find(params[:id]).update_attributes!(data)
  end
end