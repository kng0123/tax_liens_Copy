class Lien < ActiveRecord::Base

  belongs_to :township

  has_many :receipts
  has_many :subsequents
  has_many :mua_accounts

  has_and_belongs_to_many :owners
  has_and_belongs_to_many :llcs
  has_many :notes

  before_save :set_bid, :set_premium

  def set_premium
    if self.premium.nil?
      self.premium = 0
    end
  end

  def set_bid
    if self.winning_bid.nil?
      self.winning_bid = 0
    end
  end

  def note_text
    notes = self.notes
    if notes.count != 0
      return notes.first.comment
    end
  end

  def self.import_json(json, test=false)
    liens = []
    subs = []
    mua_accounts = {}
    receipts = []
    townships = {}
    owners = {}
    llcs = {}

    json[:liens].each do |data|
      #For each row iterate through each column
      begin
        data[:assessed_value] = data[:assessed_value].to_f
        data[:tax_amount] = data[:tax_amount].to_f
        data[:cert_fv] = data[:cert_fv].to_f
        data[:total_paid] = data[:total_paid].to_f
        data[:total_cash_out] = data[:total_cash_out].to_f
        data[:total_interest_due] = data[:total_interest_due].to_f
        data[:search_fee] = data[:search_fee].to_f
        data[:yep_interest] = data[:yep_interest].to_f
        data[:premium] = data[:premium].to_f
        data[:recording_fee] = data[:recording_fee].to_f
        data[:flat_rate] = data[:flat_rate].to_f
        data[:cert_int] = data[:cert_int].to_f
        data[:redemption_amount] = data[:redemption_amount].to_f

        lien = Lien.new
        lien.sale_date = Chronic.parse data[:sale_date]
        lien.county = data[:county]
        lien.year = data[:year]
        lien.block_lot = data[:block_lot]
        lien.block = data[:block]
        lien.lot = data[:lot]
        lien.qualifier = data[:qualifier]
        lien.adv_number = data[:advance_number]
        lien.lien_type = data[:lien_type]
        lien.list_item = data[:list_item]
        lien.longitude = data[:longitude]
        lien.latitude = data[:latitude]
        lien.assessed_value = (data[:assessed_value]*100).round
        lien.tax_amount = (data[:tax_amount]*100).round
        lien.status = data[:status]
        lien.cert_fv = (data[:cert_fv]*100).round
        lien.winning_bid = data[:winning_bid]
        lien.total_paid = (data[:total_paid]*100).round
        lien.total_cash_out = (data[:total_cash_out]*100).round
        lien.total_interest_due = (data[:total_interest_due]*100).round
        lien.search_fee = (data[:search_fee]*100).round
        lien.yep_interest = (data[:yep_interest]*100).round
        lien.cert_number = data[:cert_number]
        lien.address = data[:address]
        lien.premium = (data[:premium]*100).round
        lien.recording_fee = (data[:recording_fee]*100).round
        lien.recording_date = Chronic.parse  data[:recording_date]
        lien.flat_rate = (data[:flat_rate]*100).round
        lien.cert_int = (data[:cert_int]*100).round
        lien.yep_2013 = data[:yep_2013]
        lien.picture = data[:picture]
        lien.redemption_date = Chronic.parse data[:redemption_date]
        lien.redemption_amount = (data[:redemption_amount]*100).round
        lien.city = data[:city]
        lien.state = data[:state]
        lien.zip = data[:zip]
        lien.text_pad = data[:notes]

        #townships
        township = townships[data[:county]]
        township = Township.where(:name=>data[:county]).first unless township
        township = Township.new(:name=>data[:county]) unless township
        townships[data[:county]] = township
        lien.township = township

        #llcs
        llc = llcs[data[:llc]]
        llc = Llc.where(:name=>data[:llc]).first if llc.nil?
        llc = Llc.new(:name=>data[:llc]) unless llc
        llcs[data[:llc]] = llc
        lien.llcs <<  llc

        #mua_accounts
        # mua_account = MuaAccount.new(:account_number=>value)
        # mua_accounts[value] = mua_account
        # mua_account.lien = lien

        # owners
        owner = Owner.new(:name=>data[:current_owner])
        owners[data[:current_owner]] = owner
        lien.owners << owner

        # subsequents
        if data[:subsequents]
          data[:subsequents].each do |sub_data|
            next if sub_data[:amount].nil?
            sub = Subsequent.new
            sub.sub_type = sub_data[:type]
            sub.sub_date = Chronic.parse sub_data[:date]
            sub_data[:amount] = sub_data[:amount].to_f
            sub.amount = (sub_data[:amount]*100).round
            sub.lien = lien
            subs.push(sub)
          end
        end

        # receipts
        if data[:receipts]
          data[:receipts].each do |receipt_data|
            next if receipt_data[:amount].nil? or receipt_data[:deposit_date].nil?
            receipt = Receipt.new
            receipt.check_date = Chronic.parse receipt_data[:receipt_date]
            receipt.deposit_date = Chronic.parse receipt_data[:deposit_date]
            receipt.check_number = receipt_data[:check_number]
            receipt_data[:amount] = receipt_data[:amount].to_f
            receipt.check_amount = (receipt_data[:amount]*100).round
            receipt.receipt_type = self.check_tags(receipt_data[:type])
            receipt.lien = lien
            receipts.push(receipt)
          end
        end

        liens.push(lien)
      rescue => error
        puts error.backtrace
        puts data
        throw "ERROR"
      end
    end

    if !test
      ActiveRecord::Base.transaction do
        receipts.each do |receipt|
          if receipt.invalid?
            puts "INVALID"

            puts receipt.inspect
          else
            receipt.save!
          end
        end
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

  def self.import(file, test=false)
    spreadsheet = open_spreadsheet(file)

    header = []
    puts "ERE"
    puts spreadsheet
    puts spreadsheet.last_row
    header_row = spreadsheet.row(0  )
    puts "THERE"
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
      begin
        lien = Lien.new
        values = []
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
          values.push(value)
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
      rescue
        puts "ASDASD"
        return 'Error occured for data: ' + values.join(',')
      end
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
    filename = file.path
    ext = File.extname(file.path)
    begin
      filename = file.original_filename
      ext = File.extname(file.original_filename)
    rescue
    end

    case ext
    when ".csv" then Csv.new(file.path, nil, :ignore)
    when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Spreadsheet.open file.path, extension: :xlsx
    else raise "Unknown file type: #{filename}"
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
    elsif input == 'misc'
      return 'misc'
    else
      raise 'Undefined check type ' + input
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
      #{}"YEP Int" =>"yep_int",
      "Picture" =>"picture"
    }
  end

  def flat_rate
    if self.redeem_in_10
      return 0
    end
    cert_fv = self.cert_fv
    rate = 0.06
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

  def total_paid_calc(effective_date = nil)
    cert_fv = self.cert_fv || 0
    premium = self.premium || 0

    return cert_fv+premium
  end

  def total_cash_out_calc(effective_date = nil)
    cert_fv = self.cert_fv || 0
    premium = self.premium || 0
    recording_fee = self.recording_fee || 0
    subs_paid = self.subsequents.reduce(0) {|total, sub |
      if sub.void
        total
      end
      if effective_date.nil? or sub.sub_date < effective_date
        total+ sub.amount_calc
      else
        total
      end
    } || 0

    return cert_fv+premium+recording_fee+subs_paid
  end

  def total_legal_paid_calc(effective_date = nil)
    return self.receipts.reduce(0) {|total, receipt |
      if receipt.void
        total
      end
      if receipt.receipt_type != 'legal'
        total
      elsif effective_date.nil? or receipt.deposit_date < effective_date
        total+ receipt.amount
      else
        total
      end
    } || 0
  end
  #TODO: What is YEP
  def total_interest_due_calc(redeem_date = nil)
    if self.redemption_date.nil?
      return 0
    end
    return self.flat_rate()  + self.cert_interest(redeem_date) + self.sub_interest(redeem_date)
  end

  def principal_balance(effective_date = nil)
    return self.total_cash_out_calc(effective_date) - self.total_principal_paid(effective_date)
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
    when 'legal'
      0
    else
      0
    end
  end

  def total_check_calc(effective_date = nil)
    return self.receipts.reduce(0) {|total, check|
      if check.void || check.receipt_type == 'legal'
        total
      end
      if effective_date.nil? or effective_date > check.deposit_date
        total + check.amount()
      else
        total
      end
    }
  end

  def total_principal_paid(effective_date = nil)
    return self.receipts.reduce(0) {|total, check|
      if check.void || check.receipt_type == 'legal'
        total
      end
      if effective_date.nil? or effective_date > check.deposit_date
        total + check.principal_paid()
      else
        total
      end
    } || 0
  end

  def total_actual_interest(effective_date = nil)
    return self.receipts.reduce(0) {|total, check|
      if check.void || check.receipt_type == 'legal'
        total
      end
      if effective_date.nil? or effective_date > check.deposit_date
        total + check.actual_interest()
      else
        total
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
