var accounting = require('accounting')
var XLSX = require('xlsx-browserify-shim');

import {LienSub, Lien, LienCheck, LienNote} from '../classes'

var range = function* (begin, end, interval = 1) {
  for (let i = begin; i < end; i += interval) {
    yield i;
  }
}
var tags = {
  "Unique ID": "unique_id",
  "County": "county",
  "Year": "year",
  "LLC": "llc",
  "Block/Lot": "block_lot",
  "Block": "block",
  "Lot": "lot",
  "Qualifier": "qualifier",
  "Adv #": "adv_number",
  "MUA Acct # / Parcel ID": "mua_account_number",
  "Cert #": "cert_number",

  "Lien Type": "lien_type",
  "List Item": "list_item",
  "Current Owner": "current_owner",
  "Longitude ": "longitude",
  "Latitude": "latitude",
  "Assessed Value": "assessed_value",
  "Tax Amount": "tax_amount",
  "Status": "status",
  "Address": "address",
  "Cert FV": "cert_fv",
  "Winning Bid": "winning_bid",
  "Premium": "premium",
  "Total Paid": "total_paid",
  "Sale Date": "sale_date",
  "Recording Fee": "recording_fee",
  "Recording Date": "recording_date",
  "Search Fee": "search_fee",
  "Flat Rate": "flat_rate",
  "Cert Int": "cert_int",
  "2013 YEP": "2013_yep",
  "YEP Int": "yep_int",
  "Picture": "picture",
  "Redemption Date": "redemption_date",
  "Redemption": "redemption_amt",
  "Total Cash Out": "total_cash_out",
  "Total Int Due": "total_int_due",
  "MZ Check": "mz_check"
}

class LienXLSX extends Parse.Object {
  constructor(data) {
    // Pass the ClassName to the Parse.Object constructor
    super('LienXLSX');
    this.processData(data)
    // All other initialization
  }

  processData(data) {
    var workbook = XLSX.read(data, {
      type: 'binary',
      cellStyles: true //To get groups
    })

    this.sheet = workbook.Sheets["Sheet1"]
    var groups = this.getHeaders()
    this.objects = this.parseObjects(groups)
    this.liens = this.objects.map(function(lien) {
      return Lien.init_from_json(lien);
    })
    this.liens[0].save()

  }

  getRange() {
    var range = XLSX.utils.decode_range(this.sheet['!ref'])

    var cs = range.e.c
    var rs = range.e.r
    return {rows: rs, cols:cs}
  }

  getKey(x, y) {
    return XLSX.utils.encode_cell({c:x, r:y})
  }

  getCell(x, y) {
    return this.sheet[this.getKey(x, y)]
  }

  //Get the header row of the excel file
  //Strategy:
  //   Select the row the headers are on
  //   Split the headers into groups based on the color of the cell
  getHeaders() {
    var {rows, cols} = this.getRange()
    //Group cells by background color into arrays
    var group_color_break = null
    var groups = []
    var group = null

    var row = 2 //This is the row the headers are on
    var last = undefined;
    for( var col of range(0, cols) ) {
      var cell = this.getCell(col, row)

      //If this cell is empty add it to the group and move to the next one
      if (cell == undefined) {
        group.push(undefined)
        continue
      }

      //Check foregroup color
      var cellFgColor = {}
      if (cell.s) {
        cellFgColor = cell.s.fgColor
      }
      var fg_color = cellFgColor.theme+cellFgColor.tint+cellFgColor.rgb

      //If the foreground color has changed start a new grouping
      //Else do nothing
      if( group_color_break != fg_color){
        group_color_break = fg_color
        //Set the last col of the group and then reset
        if( group ){
          group.last = last
        }
        group = []
        group.first = col
        group.theme = fg_color
        groups.push(group)
      }
      last = col
      group.push(cell.w)
    }

    return groups
  }

  parseObjects (groups){
    var {rows, cols} = this.getRange()

    var objects = []
    for( var row of range(3, rows) ) {
      var object = {annotations:[], general:{}, subs:[], checks:[], season:[]}
      objects.push(object)
      for(var g of range(0, groups.length) ) {
        var group = groups[g]
        if(group.length == 15) {
          this.parseSub(object, group, row)
        } else if (group.length == 9) {
          this.parseCheck(object, group, row)
        } else if (group.length == 4){
          //DO NOTHING
        } else {
          // this.parseGeneral(object, group, row)
        }
      }
    }
    return objects
  }

  parseSub (object, group, row) {
    var first = group.first
    var last = group.last

    var tax = this.getCell(first, row)
    var tax_date = this.getCell(first+1, row)
    var util = this.getCell(first+7, row)
    var util_date = this.getCell(first+8, row)
    var total = this.getCell(first+14, row)
    if( tax_date ){
      var sub = {
        type: 'tax',
        sub_date: tax_date.w,
        amount: tax.v,
        interest: undefined,
        check: undefined
      }
      object.subs.push(sub)
    }
    if( util_date ){
      var sub = {
        type: 'utility',
        sub_date: util_date.w,
        amount: util.v,
        interest: undefined,
        check: undefined
      }
      object.subs.push(sub)
    }
  }

  parseCheck (object, group, row) {
    var first = group.first
    var last = group.last

    var check_date = this.getCell(first, row) || {}
    var deposit_date = this.getCell(first+1, row) || {}
    var check_number = this.getCell(first+2, row) || {}
    var check_amount = this.getCell(first+3, row) || {}
    var type = this.getCell(first+4, row) || {}
    var dif = this.getCell(first+5, row) || {}
    var check_principal = this.getCell(first+6, row) || {}
    var check_interest = this.getCell(first+7, row) || {}

    if( check_date ) {
      var check = {
        check_date: check_date.w,
        deposit_date: deposit_date.w,
        check_number: check_number.w,
        check_amount: check_amount.w,
        type: type.w,
        dif: dif.w,
        check_principal: check_principal.w,
        check_interest: check_interest.w
      }
      object.checks.push(check)
    }
  }

  parseSeason () {
    //TODO: I'm not sure what to do with these last fields
    //TODO: Theyre deprecated. Nothing to do
  }

  parseGeneral (object, group, row) {
    var first = group.first
    var last = group.last

    for( var col of range(first, last) ) {
      var head = this.getCell(col, 2) || {}
      var data = this.getCell(col, row)

      var notes = []
      var val = ""
      if(data) {
        if( data.w) {
          val = data.w.trim()
        }
        if(data.c) {
          notes = data.c
        }
      }

      var tag_text = head.v
      var tag = tags[tag_text]
      if(tag) {
        object.general[tag] = val
        object.annotations = object.annotations.concat(notes.map(function(note) {
          return {
            author: note.a,
            comment: note.t.split('\n')[1],
            tag: tag
          }
        }))
      }
    }
  }
}

module.exports = LienXLSX
