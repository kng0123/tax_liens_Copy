
class LiensController < ApplicationController
  respond_to :json, :xls
  skip_before_action :verify_authenticity_token

  # GET /api/lists/:list_id/todos
  def index
    puts params
    data = Lien.includes(:township, :subsequents, :receipts, :owners, :mua_accounts)
    if !(params[:id].nil? or params[:id].empty?)
      data = Lien.joins(:township).includes(:township, :subsequents, :receipts, :owners, :mua_accounts).where({id:params[:id]})
    else
      if !(params[:township].nil? or params[:township].empty?)
        data = data.where(townships:{name:params[:township]})
      end
      if !(params[:block].nil? or params[:block].empty?)
        data = data.where({block:params[:block]})
      end
      if !(params[:lot].nil? or params[:lot].empty?)
        data = data.where({lot:params[:lot]})
      end
      if !(params[:qualifer].nil? or params[:qualifer].empty?)
        data = data.where({qualifer:params[:qualifer]})
      end
      if !(params[:cert].nil? or params[:cert].empty?)
        data = data.where({cert_number:params[:cert]})
      end
      if !(params[:sale_year].nil? or params[:sale_year].empty?)
        year = params[:sale_year].to_i
        year_begin = Date.new(year, 1, 1)
        year_end = Date.new(year, 12, 31)
        data = data.where(:sale_date => year_begin..year_end)
      end
    end

    respond_with data.to_json(:include => [:township, :subsequents, :receipts, :owners, :mua_accounts])
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
