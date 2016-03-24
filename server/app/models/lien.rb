class Lien < ActiveRecord::Base

  belongs_to :township

  has_many :receipts
  has_many :subsequents
  has_many :mua_accounts

  has_and_belongs_to_many :owners
  has_and_belongs_to_many :llcs
  has_and_belongs_to_many :notes

  def self.import(file)
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
    mua_accounts = []
    receipts = []
    townships = {}
    owners = {}
    llcs = {}

    (header_row+1..spreadsheet.last_row+1).each do |row|
      #For each row iterate through each column
      lien = Lien.new
      (1..spreadsheet.last_column+1).each do |col|
        #Skip empty columns
        header_key = header[col-1]
        next unless header_key

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
          owner = Owner.where(:name=>value).first
          owner = owners[value] if owner.nil?
          owner = Owner.new(:name=>value) unless owners[value]

          owners[value] = owner
          lien.owners << owner
        elsif tag.match(/llc/)
          llc = Llc.where(:name=>value).first
          llc = llcs[value] if llc.nil?
          llc = Llc.new(:name=>value) unless llc
          llcs[value] = llc
          lien.llcs <<  llc
        elsif tag.match(/mua_account_number/)
          mua_account = MuaAccount.new
          mua_account.account_number = value
          mua_accounts.push mua_account

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
            township = Township.where(:name=>value).first
            township = townships[value] unless township
            township = Township.new(:name=>value) unless township
            townships[value] = township
            lien.township = township
          end
          lien[tag] = value
        end
      end
      liens.push(lien)
    end
    liens.each do |lien|
      lien.save
    end
    subs.each do |sub|
      sub.save
    end
    receipts.each do |receipt|
      receipt.save
    end
    mua_accounts.each do |receipt|
      receipt.save
    end

    townships.each do |key, value|
      value.save
    end
    owners.each do |key, value|
      value.save
    end
    llcs.each do |key, value|
      value.save
    end
    return townships
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
      "Search Fee" =>"search_fee",
      "Flat Rate" =>"flat_rate",
      "Cert Int" =>"cert_int",
      "2013 YEP" =>"yep_2013",
      "YEP Int" =>"yep_int",
      "Picture" =>"picture"
    }
  end

end
