class TtgController < ApplicationController
  layout 'app'
  before_action :authenticate_user!
  
  def index
  end

end
