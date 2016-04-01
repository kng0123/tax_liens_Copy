class Subsequent < ActiveRecord::Base

  belongs_to :lien
  belongs_to :subsequent_batch
  has_and_belongs_to_many :notes

  def amount_calc
    if( self.void )
      return 0
    end
    return self.amount
  end

  def interest()
    lien = self.lien
    sub_total_before = lien.total_subs_before_sub(self)
    cert_fv = lien.cert_fv
    sub_amount = self.amount_calc

    interest = 0
    days = lien.redeem_days(self.sub_date)

    if (sub_total_before + cert_fv >= 150000)
      interest = self.amount_calc * (days/365) * 0.18
    else
      if (sub_total_before + cert_fv + sub_amount <= 1500) 
        interest = self.amount_calc * (days/365) * 0.08
      else
        low_interest = 150000 - (cert_fv + sub_total_before)
        high_interest = sub_amount - low_interest
        interest = low_interest * (days/365) * 0.08 + high_interest * (days/365) * 0.18
      end
    end

    return interest
  end

end
