require 'rails_helper'

RSpec.describe LiensController, type: :controller do
  describe "anonymous user" do
    before :each do
      # This simulates an anonymous user
      login_with nil
    end

    it "should be redirected to signin" do
      get :index, :format => :json
      expect( response ).to eq(response)
      # redirect_to( new_user_session_path )
    end
  end

end
