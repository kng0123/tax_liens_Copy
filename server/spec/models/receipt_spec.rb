require 'rails_helper'

RSpec.describe Receipt, type: :model do
  describe 'receipt' do
    before :each do
      @receipt = create :receipt
    end

    it 'should work' do
      expect(@receipt.id).to eq(@receipt.id)
    end

    describe 'amount' do
    end
    describe 'principal_balance' do
    end
    describe 'principal_paid' do
    end
    describe 'total_with_interest' do
    end
    describe 'actual_interest' do
    end
  end
end
