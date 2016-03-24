class SubsequentsController < ApplicationController
  respond_to :json

  # GET /api/lists/:list_id/todos
  def index
    if params[:lien_id]
      respond_with Lien.includes(:receipts).find(params[:lien_id]).subsequents
    end
  end

  # POST /api/lists/:list_id/todos
  def create
    if params[:lien_id]
      lien = Lien.find(params[:lien_id])
      subsequent = Subsequent.create!(params)
      subsequent.lien = lien
      subsequent.save!
      respond_with subsequent
    end
  end

  # GET /api/lists/:list_id/todos/:id
  def show
    respond_with Subsequent.find(params[:id])
  end

  # PUT/PATCH /api/lists/:list_id/todos/:id
  def update
    respond_with Subsequent.find(params[:id]).update_attributes!(params)
  end
end
