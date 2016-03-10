var accounting = require('accounting')
var XLSX = require('xlsx-browserify-shim');
var Parse = require('parse')
var Models = require('../classes')

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
  "Longitude": "longitude",
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

class LienXLSX {
  constructor(data) {
    this.townships = []
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
    this.groups = groups
    this.objects = this.parseObjects(groups)

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
  getHeaders(row=0) {
    var {rows, cols} = this.getRange()
    //Group cells by background color into arrays
    var group_color_break = null
    var groups = []
    var group = null

    var last = undefined;
    for( var col of range(0, cols) ) {
      var cell = this.getCell(col, row)

      //If this cell is empty add it to the group and move to the next one
      if (cell == undefined) {
        if(group == null) {
          break;
        }
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
    if( groups.length < 2) {
      return this.getHeaders.call(this,++row)
    } else {
      this.header_row = row
      return groups
    }
  }

  parseObjects (groups){
    var {rows, cols} = this.getRange()

    var objects = []
    for( var row of range(this.header_row+1, rows+1) ) {
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
          this.parseGeneral(object, group, row)
        }
      }
      //Add Owners
      object.owners = [
        {llc: object.general.llc, start_date: new Date()}
      ]
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
    if( tax_date && tax_date.w){
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



    if( check_date && check_date.w ) {
      type = type.w.toLowerCase()
      if(type == 'combined') {
        type = 'combined'
      } else if (type == 'premium only') {
        type = 'premium'
      } else if (type == 'cert only') {
        type = 'cert_w_interest'
      } else {
        debugger
        throw new Error('Undefined check type')
      }
      var check = {
        check_date: check_date.w,
        deposit_date: deposit_date.w,
        check_number: check_number.w,
        check_amount: check_amount.w,
        type: type,
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

    for( var col of range(first, last+1) ) {
      var head = this.getCell(col, this.header_row) || {}
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

      var tag_text = head.v.trim()
      var tag = tags[tag_text]
      if(val == "") {
        val  = undefined
      }

      if(tag) {
        if(tag == 'county') {
          this.addTownship(val)
        } else if (tag == 'status' && val) {
          val = val.toLowerCase()
        }
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

  addTownship(val) {
    if(this.townships.indexOf(val) == -1 ){
      this.townships.push(val)
    }
  }

  create() {
    //Create townships
    var promises = this.townships.map( (ts) => {
      return Models.Township.findOrCreate(ts)
    })
    //Create MUA accounts
    //Create LLCs

    return Parse.Promise.when(promises).then( (townships) =>{
      var towns = townships.reduce( (m, ts) => { m[ts.get('township')] = ts; return m;}, {})
      return Parse.Object.saveAll(this.objects.map( (lien, k) =>{
      //TODO: UPgrade request limit
      // return Parse.Promise.when(this.objects.slice(0,100).map( (lien, k) =>{
        lien.general['township'] = towns[lien.general['county']]
        return Models.Lien.init_from_json(lien)
      }))
    }).then( (liens) => {
      return Parse.Object.saveAll(this.objects.map( (lien_object, k) =>{
        return Models.Lien.save_json(liens[k], lien_object)
      }))
    }).then( (liens) => {
      //Parse out SubBatches
      var sub_batches = {}
      liens.map( (lien) => {
        var township = lien.get('township').get('township')
        var subs = lien.get('subs')
        var sub_dates = []
        subs.map( (sub) => {
          var sub_date = moment(sub.get('sub_date')).format('MM/DD/YYYY')
          if( !sub_batches[township+sub_date]) {
            sub_batches[township+sub_date] = {
              sub_date: sub.get('sub_date'),
              township:lien.get('township'),
              subs: [],
              liens: []
            }
          }
          if( sub_dates.indexOf(sub_date) == -1 ) {
            sub_dates.push(sub_date)
          }
          sub_batches[township+sub_date].subs.push(sub)
        })
        //Add the Lein to each batch
        sub_dates.map((date) => {
          sub_batches[township+date].liens.push(lien)
        })
      })
      $.post('/counter', {count: liens.length}, function(data) {
        var start = data.seq + 1
        var end = start+liens.length-1
        for(var i=start, j=0; i<=end; i++, j++) {
          liens[j].set('seq_id', i)
        }
        Parse.Object.saveAll(liens)
      })

      return Parse.Promise.when(Object.keys(sub_batches).map( (key) =>{
        var batch = sub_batches[key]
        return Models.SubBatch.init_from_json(batch).save()
      }))
    })
  }
}

module.exports = LienXLSX
