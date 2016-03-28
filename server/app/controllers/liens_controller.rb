
class LiensController < ApplicationController
  respond_to :json, :xls
  skip_before_action :verify_authenticity_token

  # GET /api/lists/:list_id/todos
  def index
    puts params
    if params[:id]
      data = Lien.joins(:township).includes(:township, :subsequents, :receipts, :owners, :mua_accounts).find(params[:id])
    elsif params[:township]
      data = Lien.joins(:township).includes(:township, :subsequents, :receipts, :owners, :mua_accounts).where(townships:{name:params[:township]})
    else
      data = Lien.includes(:township, :subsequents, :receipts, :owners)
    end
    respond_with data, :include => [:township, :subsequents, :receipts, :owners, :mua_accounts]
  end

  # POST /api/lists/:list_id/todos
  def create
    respond_with Lien.create!(params.data)
  end

  # GET /api/lists/:list_id/todos/:id
  def show
    respond_with Lien.includes(:township, :subsequents, :receipts, :owners, :llcs).find(params[:id]),
      :include => [:township, :subsequents, :receipts, :owners, :llcs]
  end

  # PUT/PATCH /api/lists/:list_id/todos/:id
  def update
    data = params.permit(Lien.column_names)
    respond_with Lien.find(params[:id]).update_attributes!(data)
  end

  def import
    liens = Lien.import(params[:file], params[:test])
    d = {:data => liens}
    render json: d
    # redirect_to root_url, notice: "Liens imported."
  end

  def export_liens
    @liens =  Lien.includes(:township, :subsequents, :receipts, :owners)
    respond_with @liens, :template => 'liens/export_liens', :include => [:township, :subsequents, :receipts, :owners]
  end

  def export_receipts
    @liens =  Lien.includes(:township, :subsequents, :receipts, :owners)
    respond_with @liens, :template => 'liens/export_receipts', :include => [:township, :subsequents, :receipts, :owners]
  end

end
