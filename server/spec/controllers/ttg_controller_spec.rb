require 'rails_helper'

RSpec.describe TtgController, type: :controller do
  describe "logged in user" do
    before :each do
      @user = create(:user)
      login_with @user
    end
    it "should let a user see all the posts" do
      get :index
      expect( response ).to render_template( :index )
    end
  end

  describe "no user" do
    it "should let a user see all the posts" do
      get :index
      expect( response ).to redirect_to( new_user_session_path )
    end
  end
end
