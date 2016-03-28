class SubsequentBatch < ActiveRecord::Base

  has_many :subsequents
  belongs_to :township
  has_many :lien_subsequent_batch
  has_many :liens, :through => :lien_subsequent_batch#, :through => :subsequents
  
end

class LienSubsequentBatch < ActiveRecord::Base
  belongs_to :lien
  belongs_to :subsequent_batch
end
