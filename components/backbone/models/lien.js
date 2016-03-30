var Backbone = require('backbone');
var RelationalModel = require('backbone-relational')
var accounting = require('accounting')

class Lien extends Backbone.RelationalModel {
  static relations() {
    return LienRelations
  }
  relations() {
    return LienRelations
  }
  constructor(options) {
    super(options);
  }
  flat_rate() {
    //If redeem within 10 days then 0
    if (this.redeem_in_10()) {
      return 0
    }
    var cert_fv = this.get('cert_fv')
    var rate = 0.06 //If fv >=1000
    if ( cert_fv < 500000) {
      rate = 0.02
    } else if (cert_fv >= 500000 && cert_fv < 1000000) {
      rate = 0.04
    }
    return accounting.unformat(cert_fv * rate)
  }

  search_fee() {
    //If redeem within 10 days then 0
    if (this.redeem_in_10()) {
      return 0
    }
    return this.get('search_fee')
  }

  redeem_in_10() {
    return !!this.get('redeem_in_10')
  }

  subs_paid() {
    var subs_paid = this.get('subsequents').models.reduce((total, sub)=>{
      return total+sub.amount()
    }, 0)
    return subs_paid
  }

  total_cash_out() {
    var cert_fv = this.get('cert_fv') || 0
    var premium = this.get('premium') || 0
    var recording_fee = this.get('recording_fee') || 0
    var subs_paid = this.get('subsequents').models.reduce((total, sub)=>{
      return total+sub.amount()
    }, 0)
    return cert_fv+premium+recording_fee+subs_paid
  }
  //TODO: What is YEP
  total_interest_due() {
    if (!this.get('redemption_date')) {
      return 0
    }
    return this.flat_rate()  + this.cert_interest() + this.sub_interest()
  }
  principal_balance() {
    if(this.total_cash_out()<this.total_check()) {
      return 0
    }
    return this.total_cash_out()-this.total_check();
  }
  expected_amount() {
    return this.total_cash_out()  + this.total_interest_due() + this.get('search_fee')
  }
  receipt_expected_amount(type, sub_index) {
    //TODO Sub Payment Only
    //TODO MISC
    //TODO SOLD
    if(type == 'combined') {
      return this.expected_amount()
    } else if (type == 'cert_w_interest') {
      return this.expected_amount() - this.get('premium')
    } else if (type == 'premium') {
      return this.get('premium')
    } else if (type == 'sub_only') {
      return this.get('subsequents').models[sub_index].amount
    }
    return 0
  }
  total_check() {
    return this.get('receipts').reduce((total, check) =>{
      return total + check.amount()
    }, 0)
  }
  diff() {
    if (!this.get('redemption_date')) {
      return 0
    }
    return this.expected_amount() -this.total_check()
  }

  sub_interest() {
    return this.get('subsequents').models.reduce((total, sub) => {
      return total + sub.interest()
    }, 0)
  }

  redeem_days(date) {
    if(!date) {
      date = moment(this.get('sale_date'))
    } else {
      moment(date)
    }

    if (!this.get('redemption_date')) {
      return 0
    }
    var redemption_date = moment(this.get('redemption_date'))
    var duration = moment.duration(redemption_date.diff(date));
    var days = duration.asDays();
    return Math.round(days)
  }

  cert_interest() {
    if (!this.get('redemption_date')) {
      return 0
    }
    var days = this.redeem_days()

    var interest_rate = this.get('winning_bid')/100

    var int =  (days / 365) * interest_rate * this.get('cert_fv')
    return int
  }

  total_subs_before_sub(sub) {
    var base_date = moment(sub.get('date'))

    var subs = this.get('subsequents').models
    var total = subs.reduce((prev, curr)=>{
      if(curr.get('void')) {
        return 0
      }
      var sub_date = moment(curr.get('date'))
      if(sub_date < base_date) {
        prev = prev + curr.get('amount')
      }
      return prev
    }, 0)
    return total
    //How do we handle tie breakers
  }
  // Note the omission of the 'function' keyword— it is entirely optional in
  // ES6.
  url() {
    return '/liens/'+this.get('id')
  }

  // *Define some default attributes for the todo.*
  defaults() {
    return {
    };
  }

  save() {
    super.save({},{
      success:(i, data) => {
        this.set(data)
      }, error: function() {
      }
    })
  }
}

class LienCollection extends Backbone.Collection{
  // #### Constructors and Super Constructors
  // Specifying a `constructor` lets us define the class constructor. Use of the
  // `super` keyword in your constructor lets you call the constructor of a parent
  // class so that it can inherit all of its properties.
  constructor(options) {
    super(options);

    // *Hold a reference to this collection's model.*
    this.model = Lien;
  }
  url() {
    return '/liens'
  }
}


class Subsequent extends Backbone.RelationalModel {
  static relations() {
    return SubsequentRelations
  }
  relations() {
    return SubsequentRelations
  }
  static code_options() {
    return [
      {label: 'Tax', value:'tax'},
      {label: 'Utility', value:'utility'},
      {label: 'Other', value:'other'}
    ]
  }

  name() {
    return this.get('type')+" "+this.get('amount')+" "+moment(this.get('sub_date')).format('MM/DD/YYYY')
  }

  amount() {
    if( this.get('void')) {
      return 0
    }
    return this.get('amount')
  }

  interest() {
    var lien = this.get('lien')
    var sub_total_before = lien.total_subs_before_sub(this)
    var cert_fv = lien.get('cert_fv')
    var sub_amount = this.amount()

    var interest = 0
    var days = lien.redeem_days(this.get('sub_date'))

    if (sub_total_before + cert_fv >= 150000) {
      interest = this.amount() * (days/365) * 0.18
    } else {
      if (sub_total_before + cert_fv + sub_amount <= 1500) {
        interest = this.amount() * (days/365) * 0.08
      } else {
        var low_interest = 150000 - (cert_fv + sub_total_before)
        var high_interest = sub_amount - low_interest
        interest = low_interest * (days/365) * 0.08 + high_interest * (days/365) * 0.18
      }
    }

    return interest
  }
  constructor(options) { super(options); }
  url() {
    if(this.get('id')) {
       return '/subsequents/'+this.get('id')
    } else {
      return '/subsequents'
    }
  }
  defaults() { return {}; }

  // save() {
  //   super.save({},{
  //     success:(i, data) => {
  //       // debugger
  //       // this.set(data)
  //     }, error: function() {
  //     }
  //   })
  // }
}

class SubsequentCollection extends Backbone.Collection{
  constructor(options) {
    super(options);
    this.model = Subsequent;
  }
}

class Township extends Backbone.RelationalModel {
  constructor(options) { super(options); }
  url() { return '/townships/'+this.get('id')}
  defaults() { return {}; }
}
class TownshipCollection extends Backbone.Collection{
  constructor(options) {
    super(options);
    this.model = Township;
  }
  url() { return '/townships' }
}

var SubsequentBatchRelations = [{
  type: Backbone.HasMany,
  key: 'subsequents',
  relatedModel: Subsequent,
  collectionType: SubsequentCollection
},{
  type: Backbone.HasOne,
  relatedModel: Township,
  key: 'township',
  keySource: 'township_id',
  includeInJSON: 'id'
},{
  type: Backbone.HasMany,
  key: 'liens',
  relatedModel: Lien,
  collectionType: LienCollection
}]
class SubsequentBatch extends Backbone.RelationalModel {
  constructor(options) { super(options); }
  static relations() {
    return SubsequentBatchRelations
  }
  relations() {
    return SubsequentBatchRelations
  }
  url() {
    if(this.get('id')) {
       return '/subsequent_batch/'+this.get('id')
    } else {
      return '/subsequent_batch'
    }
  }
  defaults() { return {}; }
}
class SubsequentBatchCollection extends Backbone.Collection{
  constructor(options) {
    super(options);
    this.model = SubsequentBatch;
  }

  url() { return '/subsequent_batch' }
}

class Llc extends Backbone.RelationalModel {
  constructor(options) { super(options); }
  url() { return '/llcs/'+this.get('id')}
  defaults() { return {}; }
}
class LlcCollection extends Backbone.Collection{
  constructor(options) {
    super(options);
    this.model = Llc;
  }
  url() { return '/llcs' }
}
class MuaAccount extends Backbone.RelationalModel {
  constructor(options) { super(options); }
  url() { return '/mua_accounts/'+this.get('id')}
  defaults() { return {}; }
}
class MuaAccountCollection extends Backbone.Collection{
  constructor(options) {
    super(options);
    this.model = Llc;
  }
  url() { return '/mua_accounts' }
}

class Receipt extends Backbone.RelationalModel {
  constructor(options) { super(options); }
  static relations() {
    return ReceiptRelations
  }
  relations() {
    return ReceiptRelations
  }
  url() {
    if(this.get('id')) {
       return '/receipts/'+this.get('id')
    } else {
      return '/receipts'
    }
  }
  defaults() { return {}; }
  amount() {
    if(this.get('void')){
      return 0
    } else {
      return this.get('check_amount')
    }
  }

  expected_amount() {
    var type = (this.get('receipt_type') || "").toLowerCase()
    //TODO Sub Payment Only
    //TODO MISC
    //TODO SOLD
    if(type == 'combined') {
      return this.get('lien').expected_amount()
    } else if (type == 'cert_w_interest') {
      return this.get('lien').expected_amount() - this.get('lien').get('premium')
    } else if (type == 'premium') {
      return this.get('lien').get('premium')
    } else if (type == 'sub_only') {
      return this.get('sub').amount
    }
    return 0
  }

  static code_options() {
    return [
      {label: 'Combined', value:'combined'},
      {label: 'Premium', value:'premium'},
      {label: 'Cert w/ Interest', value:'cert_w_interest'},
      {label: 'Sub Only', value:'sub_only'},
      {label: 'Misc', value:'misc'},
      {label: 'Sold', value:'sold'}
    ]
  }
}
class ReceiptCollection extends Backbone.Collection{
  constructor(options) {
    super(options);
    this.model = Receipt;
  }
  url() { return '/receipts' }
}

var LienRelations = [{
  type: Backbone.HasMany,
  key: 'subsequents',
  relatedModel: Subsequent,
  collectionType: SubsequentCollection,
  reverseRelation: {
    key: 'lien'
  }
},{
  type: Backbone.HasMany,
  key: 'llcs',
  relatedModel: Llc,
  collectionType: LlcCollection
},{
  type: Backbone.HasMany,
  key: 'receipts',
  relatedModel: Receipt,
  collectionType: ReceiptCollection,
  reverseRelation: {
    key: 'lien'
  }
},{
  type: Backbone.HasMany,
  key: 'mua_accounts',
  relatedModel: MuaAccount,
  collectionType: MuaAccountCollection
}]
var SubsequentRelations = [{
  type: Backbone.HasOne,
  key: 'lien',
  keySource: 'lien_id',
  includeInJSON: 'id',
  relatedModel: Lien,
  reverseRelation: {
    key: 'subsequents',
    relatedModel: Subsequent,
    collectionType: SubsequentCollection
  }
}]
var ReceiptRelations = [{
  type: Backbone.HasOne,
  key: 'lien',
  keySource: 'lien_id',
  includeInJSON: 'id',
  relatedModel: Lien,
  reverseRelation: {
    key: 'receipts',
    relatedModel: Receipt,
    collectionType: ReceiptCollection
  }
}]

class JSON extends Backbone.RelationalModel {
  constructor(options) { super(options); }
  url() { return this.get('url')}
  defaults() { return {}; }
  fetch(data) {
    var collection = this;
    var str = $.param( data );
    $.ajax({
        type : 'GET',
        url : this.url()+"?"+str,
        dataType : 'json',
        success : function(data) {
            collection.set({data:data})
        }
    });
  }
}

Lien.setup()
Receipt.setup()
SubsequentBatch.setup()
Subsequent.setup()
Township.setup()
Llc.setup()

module.exports = function(b) {
  b.Models.Lien = Lien
  b.Models.JSON = JSON
  b.Models.SubsequentBatch = SubsequentBatch
  b.Models.Subsequent = Subsequent
  b.Models.Receipt = Receipt
  b.Collections.LienCollection = LienCollection
  b.Collections.TownshipCollection = TownshipCollection
  b.Collections.SubsequentBatchCollection = SubsequentBatchCollection
}
