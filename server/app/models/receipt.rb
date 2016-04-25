class Receipt < ActiveRecord::Base

  belongs_to :lien
  belongs_to :subsequent
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

  def principal_balance
    type = self.receipt_type.downcase
    if self.is_principal_override
      return self.misc_principal
    end
    case type
    when 'combined'
      return self.lien.total_cash_out_calc
    when 'cert_w_interest'
      return 0
    when 'premium'
      return self.lien.premium
    when 'sub_only'
      sub = self.subsequent
      return sub.amount if sub
      return 0
    when 'misc'
      return self.misc_principal
    else
      0
    end
  end

  def principal_paid
    due = principal_balance - amount
    if due < 0
      principal_balance
    else
      self.amount
    end
  end

  def total_with_interest(redeem_date = nil)
    type = self.receipt_type.downcase
    redeem_date = self.redeem_date if redeem_date.nil?
    case type
    when 'combined'
      return self.lien.expected_amount(self.redeem_date)
    when 'cert_w_interest'
      return self.lien.expected_amount(self.redeem_date) - self.lien.premium
    when 'premium'
      return self.lien.premium
    when 'sub_only'
      sub = self.subsequent
      return sub.amount + sub.interest(self.redeem_date) if sub
      return 0
    when 'misc'
      return self.misc_principal
    else
      0
    end
  end
  def actual_interest
    self.amount - self.principal_paid
  end
end
