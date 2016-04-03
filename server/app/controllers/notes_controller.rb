class NotesController < ApplicationController
  respond_to :json

  # GET /api/lists/:list_id/todos
  def index
  end

  # POST /api/lists/:list_id/todos
  def create
    if params[:lien_id] and current_user
      note = Note.new(
        :comment => params[:comment]
      )

      note.lien = Lien.find(params[:lien_id])
      note.save!
      respond_with note
    end
  end

  # GET /api/lists/:list_id/todos/:id
  def show
  end

  # PUT/PATCH /api/lists/:list_id/todos/:id
  def update
  end
end
