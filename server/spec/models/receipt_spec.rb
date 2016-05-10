require 'rails_helper'

RSpec.describe Receipt, type: :model do
  describe 'receipt' do
    before :each do
      @receipt = create :receipt
    end

    it 'should work' do
      expect(@receipt.id).to eq(@receipt.id)
    end
  end
end
