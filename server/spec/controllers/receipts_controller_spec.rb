require 'rails_helper'

RSpec.describe ReceiptsController, type: :controller do
  describe "anonymous user" do
    before :each do
      login_with nil
    end

    it "should not have access" do
      post :create, :format => :json
      expect( response ).to have_http_status(401)
    end
  end

  describe "logged in user" do
    before :each do
      @user = create(:user)
      @township = create(:township, :name => "Atlantic City")
      @lien = create(:lien, :township => @township)
      @subsequent = create(:subsequent, :lien => @lien)
      login_with @user
    end

    describe "create" do
      before :each do
        @params = {
          "receipt_type"=>"sub_only",
          "account_type"=>"money-market",
          "deposit_date"=>"2016-03-01T08:00:00.000Z",
          "check_date"=>"2016-03-01T08:00:00.000Z",
          "redeem_date"=>"2015-08-25",
          "check_number"=>"42",
          "check_amount"=>"545",
          "note"=>"",
          "sub"=>@subsequent,
          "is_principal_override"=>false,
          "is_principal_paid_override"=>false,
          "paid_principal"=>0,
          "lien_id"=>@lien.id,
          "subsequent_id"=>nil
        }
      end
      it 'should return the receipt' do
        post :create, @params.as_json.merge(format: :json)
        parsed_body = JSON.parse(response.body)
        expect(parsed_body["subsequent_id"]).to eq(@subsequent.id)
      end
    end

    describe "create with principal_paid" do
      before :each do
        @params = {
          "receipt_type"=>"sub_only",
          "account_type"=>"money-market",
          "deposit_date"=>"2016-03-01T08:00:00.000Z",
          "check_date"=>"2016-03-01T08:00:00.000Z",
          "redeem_date"=>"2015-08-25",
          "check_number"=>"42",
          "check_amount"=>"545",
          "note"=>"",
          "is_principal_override"=>false,
          "is_principal_paid_override"=>false,
          "paid_principal"=>400,
          "lien_id"=>@lien.id,
          "subsequent_id"=>nil
        }
      end
      it 'should return the receipt' do
        post :create, @params.as_json.merge(format: :json)
        parsed_body = JSON.parse(response.body)
        expect(parsed_body["paid_principal"]).to eq(400)
      end
    end
  end

end
