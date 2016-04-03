class TtgController < ApplicationController
  layout 'app'
  before_action :authenticate_user!

  def index
  end

  def wrong_url
    redirect_to '/app/lien'
  end

end
