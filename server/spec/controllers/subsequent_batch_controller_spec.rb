require 'rails_helper'

RSpec.describe SubsequentBatchController, type: :controller do
  describe "anonymous user" do
    before :each do
      login_with nil
    end

    it "should not have access" do
      get :index, :format => :json
      expect( response ).to have_http_status(401)
    end
  end

  describe "logged in user" do
    before :each do
      @user = create(:user)
      @township = create(:township, :name => "Atlantic City")
      @subsequent_batch = create(:subsequent_batch,
        :township => @township,
        :sub_date => Date.today
      )
      @lien = create(:lien, :township=>@township)
      @subsequent = create(:subsequent,
        :lien => @lien,
        :sub_type => 'tax',
        :amount => 4200,
        :subsequent_batch => @subsequent_batch
      )
      @subsequent_batch.liens = [@lien]
      login_with @user
    end

    describe "index" do
      it 'should return the batch' do
        params = {id:@subsequent_batch.id.to_s}
        get :index, params.merge(format: :json)
        parsed_body = JSON.parse(response.body)
        expect(parsed_body[0]["id"]).to eq(@subsequent_batch.id)
      end
    end
    describe "Exports" do
      render_views
      it "should export only the receipts in the selected range" do
        data = {id:@subsequent_batch.id.to_s}
        get :show, data.merge(:format => "xlsx")
        expect( response ).to have_http_status(200)
        File.open('/tmp/axlsx_temp.xlsx', 'w') {|f| f.write(response.body) }
        wb = nil
        expect{ wb = Roo::Excelx.new('/tmp/axlsx_temp.xlsx') }.to_not raise_error
        expect(wb.cell(4,1)).to eq("Atlantic City")
      end
    end
  end
end
