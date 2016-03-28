class Subsequent < ActiveRecord::Base

  belongs_to :lien
  belongs_to :subsequent_batch
  has_and_belongs_to_many :notes

end
