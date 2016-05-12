require 'rails_helper'

RSpec.describe LiensController, type: :controller do
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
      login_with @user
    end

    describe "index" do
      before :each do
        @lien = create(:lien)
      end
      it 'should return the lien' do
        params = {id:@lien.id.to_s}
        get :index, params.merge(format: :json)
        parsed_body = JSON.parse(response.body)
        expect(parsed_body[0]["id"]).to eq(@lien.id)
      end
    end

    describe "show" do
      before :each do
        @lien = create(:lien, :township => @township)
      end
      it 'should return the lien' do
        params = {id:@lien.id.to_s}
        get :show, params.merge(format: :json)
        parsed_body = JSON.parse(response.body)
        expect(parsed_body["id"]).to eq(@lien.id)
      end
    end

    describe "update" do
      before :each do
        @lien = create(:lien, :township => @township)
      end
      it 'should return the lien' do
        @lien.recording_fee = 4400
        data = @lien.as_json
        put :update, data.merge(format: :json)
        parsed_body = JSON.parse(response.body)
        expect(parsed_body["recording_fee"]).to eq(@lien.recording_fee)
      end
    end

    describe "import/export" do
      before :each do
        @file = fixture_file_upload('files/sample.xlsx')
        post :import, :file => @file
        @response = response
      end
      after(:each) do
        if File.exists? '/tmp/axlsx_temp.xlsx'
          File.unlink '/tmp/axlsx_temp.xlsx'
        end
      end
      it 'shuold upload some sample liens' do
        expect(response).to have_http_status(200)
        expect(Township.count).to eq(1)
        expect(Lien.count).to eq(10)
      end

      describe "Exports" do
        render_views

        describe "receipts" do
          it "should export all of the receipts" do
            data = {
              :from => "18/06/2010",
              :to =>   "06/06/2015"
            }
            get :export_receipts, data.merge(:format => "xlsx")
            expect( response ).to have_http_status(200)
            File.open('/tmp/axlsx_temp.xlsx', 'w') {|f| f.write(response.body) }
            wb = nil
            expect{ wb = Roo::Excelx.new('/tmp/axlsx_temp.xlsx') }.to_not raise_error
            expect(wb.cell(3,2)).to eq("Atlantic City")
          end
        end
        describe "export_liens" do
          it "should export all of the receipts" do
            data = {
              :start_date => "18/06/2010",
              :end_date =>   "06/06/2015",
              :sale_date =>   "06/06/2015"
            }
            get :export_liens, data.merge(:format => "xlsx")
            expect( response ).to have_http_status(200)
            File.open('/tmp/axlsx_temp.xlsx', 'w') {|f| f.write(response.body) }
            wb = nil
            expect{ wb = Roo::Excelx.new('/tmp/axlsx_temp.xlsx') }.to_not raise_error
            expect(wb.cell(3,2)).to eq("Atlantic City")
          end
        end
      end
    end
  end
end
