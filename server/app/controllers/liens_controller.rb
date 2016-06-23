
class LiensController < ApplicationController
  respond_to :json, :xls
  # before_action :authenticate_user!
  # protect_from_forgery :except => :import
  skip_before_action :authenticate_user

  # GET /api/lists/:list_id/todos
  def index
    data = Lien.includes(:township, :subsequents, :receipts, :owners, :mua_accounts)
    if !(params[:id].nil? or params[:id].empty?)
      data = Lien.joins(:township).includes(:township, :subsequents, :receipts, :owners, :mua_accounts).where({id:params[:id]})
    else
      if !(params[:township].nil? or params[:township].empty?)
        data = data.where(townships:{name:params[:township]})
      end
      if !(params[:block].nil? or params[:block].empty?)
        data = data.where('block LIKE ?', '%' + params[:block] + '%')
      end
      if !(params[:lot].nil? or params[:lot].empty?)
        data = data.where('lot LIKE ?', '%' + params[:lot] + '%')
      end
      if !(params[:qualifier].nil? or params[:qualifier].empty?)
        # data = data.where({qualifier:params[:qualifier]})
        data = data.where('qualifier LIKE ?', '%' + params[:qualifier] + '%')
      end
      if !(params[:cert].nil? or params[:cert].empty?)
        data = data.where('cert_number LIKE ?', '%' + params[:cert] + '%')
      end
      if !(params[:address].nil? or params[:address].empty?)
        data = data.where('address LIKE ?', '%' + params[:address] + '%')
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

  # GET /api/lists/:list_id/todos/:id
  def show
    respond_with Lien.includes(:township, :subsequents, :receipts, :owners, :llcs, :notes).find(params[:id]).serializable_hash(:include => [:township, :subsequents, :receipts, :owners, :llcs, :notes])
  end

  # PUT/PATCH /api/lists/:list_id/todos/:id
  def update
    data = params.permit(Lien.column_names)
    Lien.find(params[:id]).update_attributes!(data)
    render json: Lien.find(params[:id])
  end

  def import
    if params[:liens]
      liens = Lien.import_json(params, false)
    else
      begin
        liens = Lien.import(params[:file], params[:test])
      rescue Exception => e
        puts e.message
        stacktrace =  e.backtrace
        stacktrace.each { |line| puts line }
        render json: {:foo => "boo"}, :status => 500
        return
      end
    end
    d = {:data => liens}
    if liens.is_a? String
      render json: d, :status => 404
    else
      render json: d
    end
    # redirect_to root_url, notice: "Liens imported."
  end

  def export_liens
    @effective_date = Date.parse(params[:end_date])
    @start_date = Date.parse(params[:start_date])
    @end_date = Date.parse(params[:end_date])

    @liens =  Lien.includes(:township, :subsequents, :receipts, :owners).where('sale_date' => (20.years.ago)..@effective_date.end_of_day)
    render xlsx: "export_liens", :include => [:township, :subsequents, :receipts, :owners]
  end

  def export_receipts
    from = Date.parse(params[:from])
    to = Date.parse(params[:to])
    @liens =  Lien.includes(:township, :subsequents, :receipts, :owners).where('receipts.deposit_date' => from.beginning_of_day..to.end_of_day)
    render xlsx: "export_receipts", :include => [:township, :subsequents, :receipts, :owners]
    # respond_with @liens, :template => 'liens/export_receipts', :include => [:township, :subsequents, :receipts, :owners]
  end

end
