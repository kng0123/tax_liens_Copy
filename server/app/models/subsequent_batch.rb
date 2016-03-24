class SubsequentBatch < ActiveRecord::Base

  has_many :subsequents
  has_many :liens, :through => :subsequents
  
end
