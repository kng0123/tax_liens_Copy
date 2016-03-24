class Subsequent < ActiveRecord::Base

  belongs_to :lien
  has_and_belongs_to_many :notes
  
end
