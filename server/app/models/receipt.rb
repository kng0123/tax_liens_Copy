class Receipt < ActiveRecord::Base

  belongs_to :lien
  has_and_belongs_to_many :notes

  def amount
    if self.void
      return 0
    else
      self.check_amount
    end
  end

  def note_text
    notes = self.notes
    if notes.count != 0
      return notes.first.comment
    end
  end

  def expected_amount
    type = self.receipt_type.downcase
    case type
    when 'combined'
      self.lien.expected_amount
    when 'cert_w_interest'
      self.lien.expected_amount - self.lien.premium
    when 'premium'
      self.lien.premium
    when 'sub_only'
      -42
      # self.subsequent.amount
    else
      0
    end
  end
end
