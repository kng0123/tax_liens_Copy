class SubsequentBatchController < ApplicationController
  respond_to :json, :xlsx
  before_action :authenticate_user!

  # GET /api/lists/:list_id/todos
  def index
    if params[:township]
      batches =  SubsequentBatch.includes(:township, :subsequents, :liens).joins(:township).where(townships:{name:params[:township]})
    else
      batches =  SubsequentBatch.includes(:township, :subsequents, :liens).all
    end

    respond_with batches, :include => [:township, :subsequents, :liens]
  end

  # POST /api/lists/:list_id/todos
  def create
    township = Township.where(:name=>params[:data][:township]).first
    liens = Lien.where(township:township).where("liens.status not in (?) or liens.status is null", ['redeemed', 'none'])
    if(liens.length == 0)
      render :nothing => true, :status => 400
      return
    end
    batch = SubsequentBatch.new(:township=>township, :sub_date=>params[:data][:sub_date])
    batch.save
    #Add active liens to the batch
    batch.liens = liens
    respond_with batch
  end

  # GET /api/lists/:list_id/todos/:id
  def show
    @batches =  SubsequentBatch.includes(:township, :subsequents, :liens).find(params[:id])#, :include => [:township, :subsequents, :liens]
    respond_with @batches, :template => 'subsequents_batch/export', :include => [:township, :subsequents, :liens]

  end

  # PUT/PATCH /api/lists/:list_id/todos/:id
  def update
    if params.has_key?(:void)
      batch = SubsequentBatch.update(params[:id], {:void => params[:void]})
      SubsequentBatch.find(params[:id]).subsequents.update_all({:void => params[:void]})
      respond_with batch, :include => [:township, :subsequents, :liens]
    end
  end
end
