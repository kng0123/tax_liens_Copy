class TownshipsController < ApplicationController
  respond_to :json

  # GET /api/lists/:list_id/todos
  def index
    respond_with Township.all
  end

end
