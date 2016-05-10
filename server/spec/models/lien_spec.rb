require 'rails_helper'

RSpec.describe Lien, type: :model do
  describe 'lien' do
    before :each do
      @lien = create :lien
    end

    it 'should work' do
      expect(@lien.id).to eq(@lien.id)
    end
  end
end
