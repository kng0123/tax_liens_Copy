class Lien < ActiveRecord::Base

  belongs_to :township

  has_many :receipts
  has_many :subsequents
  has_many :mua_accounts

  has_and_belongs_to_many :owners
  has_and_belongs_to_many :llcs
  has_many :notes

  def note_text
    notes = self.notes
    if notes.count != 0
      return notes.first.comment
    end
  end

  def self.import(file, test=false)
    spreadsheet = open_spreadsheet(file)

    header = []
    header_row = spreadsheet.row(0  )
    (0..spreadsheet.last_row).each do |i|
      header = spreadsheet.row(i)
      if !header[0].nil?
        header_row = i
        break
      end
    end

    #TODO need to create model items
    tags = get_tags()
    liens = []
    subs = []
    mua_accounts = {}
    receipts = []
    townships = {}
    owners = {}
    llcs = {}

    (header_row+1..spreadsheet.last_row).each do |row|
      #For each row iterate through each column
      lien = Lien.new
      (1..spreadsheet.last_column+1).each do |col|
        #Skip empty columns
        header_key = header[col-1]
        next unless header_key
        begin
          header_key.strip!
        rescue
          next
        end

        #Default to the header column name
        tag = tags[header_key]
        tag = header_key unless tag

        #Skip no value
        value = spreadsheet.cell(row, col)
        next if value.nil?

        if tag == 'status' && value
          value = value.downcase()
        end

        next if tag.class == Fixnum or tag.class == Float
        if tag.match(/owner/)
          owner = Owner.new(:name=>value)
          owners[value] = owner
          lien.owners << owner
        elsif tag.match(/llc/)
          llc = llcs[value]
          llc = Llc.where(:name=>value).first if llc.nil?
          llc = Llc.new(:name=>value) unless llc
          llcs[value] = llc
          lien.llcs <<  llc
        elsif tag.match(/mua_account_number/)
          mua_account = MuaAccount.new(:account_number=>value)
          mua_accounts[value] = mua_account
          mua_account.lien = lien

        elsif tag.match(/Check Date/)
          amount = spreadsheet.cell(row, col+3)
          next if amount.nil?
          receipt = Receipt.new
          receipt.check_date = value
          receipt.deposit_date = spreadsheet.cell(row, col+1)
          receipt.check_number = spreadsheet.cell(row, col+2)
          receipt.check_amount = (amount*100).round
          receipt.receipt_type = self.check_tags(spreadsheet.cell(row, col+4))
          receipt.lien = lien
          receipts.push(receipt)

        elsif tag.match(/Tax Date/) or tag.match(/Utility Date/)
          amount = spreadsheet.cell(row, col-1)
          next if amount.nil?
          sub = Subsequent.new
          sub.sub_type = 'tax'
          sub.sub_type = 'utility' unless tag.match(/Tax Date/)
          sub.sub_date = value
          sub.amount = (amount*100).round
          sub.lien = lien
          subs.push(sub)
        elsif tags[header_key]
          if tag.match(/county/)
            township = townships[value]
            township = Township.where(:name=>value).first unless township
            township = Township.new(:name=>value) unless township
            townships[value] = township
            lien.township = township
          end
          cash_fields = [
            "cert_int",
            "flat_rate",
            "search_fee",
            "redemption_amount",
            "recording_fee",
            "premium",
            "total_paid",
            "cert_fv",
            "tax_amount",
            "assessed_value",
            "winning_bid"
          ]

          if cash_fields.include?(tag)
            value = value * 100
          end
          lien[tag] = value
        end
      end
      liens.push(lien)
    end

    if !test
      ActiveRecord::Base.transaction do
        liens.each do |lien|
          lien.save!
        end
        townships.each do |key, value|
          value.save!
        end
        subs.each do |sub|
          #Find Subsequent batch matching lien
          township = sub.lien.township
          sub_batch = SubsequentBatch.where(:township=>township, :sub_date=>sub.sub_date).first
          if sub_batch.nil?
            sub_batch = SubsequentBatch.new(:township=>township, :sub_date=>sub.sub_date)
            sub_batch.save!
          end
          sub_batch.liens << sub.lien
          sub.subsequent_batch = sub_batch
          sub.save!
        end
        receipts.each do |receipt|
          receipt.save!
        end
        mua_accounts.each do |key, value|
          value.save!
        end

        owners.each do |key, value|
          value.save!
        end
        llcs.each do |key, value|
          value.save!
        end
      end
    end
    return {
      :townships => townships,
      :llcs => llcs,
      :owners => owners,
      # :subsequent_batches => sub_batch,
      :subsequents => subs,
      :liens => liens,
      :receipts => receipts
    }
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Csv.new(file.path, nil, :ignore)
    when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

  def self.check_tags(input)
    input = input.downcase
    if input == 'combined'
      return 'combined'
    elsif input == 'premium only'
      return 'premium'
    elsif input == 'cert only'
      return 'cert_w_interest'
    else
      raise 'Undefined check type'
    end
  end

  def self.get_tags
    return {
      "County" =>"county",
      "Year" =>"year",
      "LLC" =>"llc",
      "Block/Lot" =>"block_lot",
      "Block" =>"block",
      "Lot" =>"lot",
      "Qualifier" =>"qualifier",
      "Adv #" =>"adv_number",
      "MUA Acct # / Parcel ID" =>"mua_account_number",
      "Cert #" =>"cert_number",

      "Lien Type" =>"lien_type",
      "List Item" =>"list_item",
      "Current Owner" =>"current_owner",
      "Longitude" =>"longitude",
      "Latitude" =>"latitude",
      "Assessed Value" =>"assessed_value",
      "Tax Amount" =>"tax_amount",
      "Status" =>"status",
      "Address" =>"address",
      "Cert FV" =>"cert_fv",
      "Winning Bid" =>"winning_bid",
      "Premium" =>"premium",
      "Total Paid" =>"total_paid",
      "Sale Date" =>"sale_date",
      "Recording Fee" =>"recording_fee",
      "Recording Date" =>"recording_date",
      "Redemption Date" =>"redemption_date",
      "Redemption" =>"redemption_amount",
      "Search Fee" =>"search_fee",
      "Flat Rate" =>"flat_rate",
      "Cert Int" =>"cert_int",
      "2013 YEP" =>"yep_2013",
      "YEP Int" =>"yep_int",
      "Picture" =>"picture"
    }
  end

  def flat_rate
    if self.redeem_in_10
      return 0
    end
    cert_fv = self.cert_fv
    rate = 0.06 #If fv >=1000
    if ( cert_fv < 500000)
      rate = 0.02
    elsif (cert_fv >= 500000 and cert_fv < 1000000)
      rate = 0.04
    end
    return cert_fv * rate
  end

  def search_fee_calc
    #If redeem within 10 days then 0
    if (self.redeem_in_10())
      return 0
    end
    return self.search_fee
  end

  def subs_paid
    subs_paid = self.subsequents.reduce(0) {|total, sub | total+sub.amount}
    return subs_paid
  end

  def total_cash_out_calc(effective_date = nil)
    cert_fv = self.cert_fv || 0
    premium = self.premium || 0
    recording_fee = self.recording_fee || 0
    subs_paid = self.subsequents.reduce(0) {|total, sub |
      if effective_date.nil? or sub.sub_date < effective_date
        total+ sub.amount()
      end
    } || 0
    puts subs_paid
    puts "END"
    return cert_fv+premium+recording_fee+subs_paid
  end
  #TODO: What is YEP
  def total_interest_due_calc(redeem_date = nil)
    if self.redemption_date.nil?
      return 0
    end
    return self.flat_rate()  + self.cert_interest(redeem_date) + self.sub_interest(redeem_date)
  end

  def principal_balance(effective_date = nil)
    return self.total_cash_out_calc(effective_date) - (self.search_fee || 0) - self.total_principal_paid(effective_date)
  end
  def expected_amount(redeem_date = nil, effective_date = nil)
    return self.total_cash_out_calc(effective_date)  + self.total_interest_due_calc(redeem_date) + (self.search_fee_calc || 0)
  end

  def receipt_expected_amount(type, sub_index = 0)
    case type
    when 'combined'
      self.expected_amount
    when 'cert_w_interest'
      self.expected_amount - self.premium
    when 'premium'
      self.premium
    else
      0
    end
  end

  def total_check_calc(effective_date = nil)
    return self.receipts.reduce(0) {|total, check|
      if effective_date.nil? or effective_date > check.deposit_date
        total + check.amount()
      end
    }
  end

  def total_principal_paid(effective_date = nil)
    return self.receipts.reduce(0) {|total, check|
      if effective_date.nil? or effective_date > check.deposit_date
        total + check.principal_paid()
      end
    }
  end

  def total_actual_interest(effective_date = nil)
    return self.receipts.reduce(0) {|total, check|
      if effective_date.nil? or effective_date > check.deposit_date
        total + check.actual_interest()
      end
    }
  end

  def diff
    if self.redemption_date
      return 0
    end
    if self.redemption_amount
      return self.expected_amount - self.redemption_amount
    end
    return self.expected_amount() - self.total_check_calc()
  end

  def sub_interest(redeem_date = nil )
    return self.subsequents.reduce(0) {|total, sub| total + sub.interest(redeem_date) }
  end

  def redeem_days(date, redeem_date=nil)
    if(date.nil?)
      date = self.sale_date
    else
      date = Date.today
    end

    if self.redemption_date.nil?
      return 0
    end

    redemption_date = (redeem_date or self.redemption_date)

    duration = redemption_date - date
    return duration
  end

  def cert_interest(redeem_date = nil)
    redeem_date = redeem_date or self.redemption_date
    if !redeem_date
      return 0
    end
    days = self.redeem_days(self.sale_date, redeem_date)
    if days < 0
      return 0
    end
    interest_rate = self.winning_bid / 100.0

    int =  (days / 365) * interest_rate * self.cert_fv
    puts int
    return int
  end

  def total_subs_before_sub(sub, begin_date = nil, end_date = nil)
    base_date = 0
    if !sub.nil?
      base_date = sub.sub_date
      if base_date.nil?
        return 0
      end
    end

    subs = self.subsequents
    total = 0

    subs.each do |sub_item|
      if sub_item.void or sub_item.sub_date.nil?
        next
      end
      if !begin_date.nil? and begin_date > sub_item.sub_date
        next
      end
      if !end_date.nil? and end_date < sub_item.sub_date
        next
      end

      sub_date = sub_item.sub_date
      if base_date == 0
        total = total + sub_item.amount
      elsif !sub_date.nil? and sub_date < base_date
        total = total + sub_item.amount
      end

    end
    total
  end

end
