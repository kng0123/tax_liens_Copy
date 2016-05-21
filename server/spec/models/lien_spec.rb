require 'rails_helper'

RSpec.describe Lien, type: :model do
  describe 'lien_import data' do
    before :each do
      @file = File.open("spec/fixtures/files/sample.xlsx", "r")
      @liens = Lien.import(@file)[:liens]
    end
    describe 'Lien 4' do
      before :each do
        @lien = @liens[3]
      end
      it 'should verify total subs paid' do
        expect(@lien.subs_paid).to eq(1204377)
      end
      it 'should verify total cash out' do
        expect(@lien.total_cash_out_calc).to eq(1935876)
      end
      it 'should verify principal balance' do
        expect(@lien.principal_balance).to eq(1935876)
      end
    end
  end
  describe 'lien' do
    before :each do
      @cert_fv = 499999
      @search_fee = 4200
      @lien = create( :lien,
        :cert_fv => 499999,
        :search_fee => @search_fee
      )
    end

    it 'should work' do
      expect(@lien.id).to eq(@lien.id)
    end

    describe 'flat rate' do
      it 'should be zero if redeemed in 10' do
        @lien.redeem_in_10 = true
        expect(@lien.flat_rate).to eq(0)
      end
      it 'should be 2% if below $5,000.00' do
        @lien.cert_fv = 499999
        expect(@lien.flat_rate).to eq(499999 * 0.02)
      end
      it 'should be 4% if between $5,000.00 and $10,000.00' do
        @lien.cert_fv = 500001
        expect(@lien.flat_rate).to eq(500001 * 0.04)
        @lien.cert_fv = 999999
        expect(@lien.flat_rate).to eq(999999 * 0.04)
      end
      it 'should be 6% if > $10,000.00' do
        @lien.cert_fv = 1000001
        expect(@lien.flat_rate).to eq(1000001 * 0.06)
      end
    end

    describe 'search_fee_calc' do
      it 'should work' do
        expect(@lien.search_fee_calc).to eq(@search_fee)
        @lien.redeem_in_10 = true
        expect(@lien.search_fee_calc).to eq(0)
      end
    end

    describe 'subs_paid' do
    end
    describe 'total_cash_out_calc' do
    end
    describe 'total_legal_paid_calc' do
    end
    describe 'total_interest_due_calc' do
    end
    describe 'principal_balance' do
    end
    describe 'expected_amount' do
    end
    describe 'total_check_calc' do
    end
    describe 'total_principal_paid' do
    end
    describe 'total_actual_interest' do
    end
    describe 'diff' do
    end
    describe 'sub_interest' do
    end
    describe 'redeem_days' do
    end
    describe 'cert_interest' do
    end
    describe 'total_subs_before_sub' do
    end
  end
end
