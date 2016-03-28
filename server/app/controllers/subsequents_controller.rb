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
    puts params
    if params[:lien_id]
      lien = Lien.find(params[:lien_id])
      subsequent = Subsequent.new(
        :sub_type => params[:type],
        :amount => Float(params[:amount]) * 100,
        :sub_date => params[:sub_date]
      )
      if params[:subsequent_batch_id]
        subsequent.subsequent_batch = SubsequentBatch.find(params[:subsequent_batch_id])
      end
      subsequent.lien = Lien.find(params[:lien_id])
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
    data = params.permit(Subsequent.column_names)
    respond_with Subsequent.find(params[:id]).update_attributes!(data)
  end
end
