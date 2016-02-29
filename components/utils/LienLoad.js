var accounting = require('accounting')
var Parse = require('parse')
var Models = require('../classes')

import {LienSub, Lien, LienCheck, LienNote} from '../classes'

class LienLoad {
  static create(townships, objects) {
    //Create townships
    var promises = townships.map( (ts) => {
      return Models.Township.findOrCreate(ts)
    })

    return Parse.Promise.when(promises).then( (townships) =>{
      var towns = townships.reduce( (m, ts) => {
        m[ts.get('township')] = ts
        return m
      }, {})
      return Parse.Promise.when(objects.map( (lien, k) =>{
      // return Parse.Promise.when(this.objects.slice(0,10).map( (lien, k) =>{
        lien.general['township'] = towns[lien.general['county']]
        return Models.Lien.save_json(lien)
      }))
    }).then( (liens) => {
      //Parse out SubBatches
      var sub_batches = {}
      liens.map( (lien) => {
        var township = lien.get('township').get('township')
        var subs = lien.get('subs')
        subs.map( (sub) => {
          var sub_date = moment(sub.get('sub_date')).format('MM/DD/YYYY')
          if( !sub_batches[township+sub_date]) {
            sub_batches[township+sub_date] = {
              sub_date: sub.get('sub_date'),
              township:lien.get('township'),
              subs: []
            }
          }
          sub_batches[township+sub_date].subs.push(sub)
        })
      })
      return Parse.Promise.when(Object.keys(sub_batches).map( (key) =>{
        var batch = sub_batches[key]
        return Models.SubBatch.init_from_json(batch).save()
      }))
    }).fail( (error) =>{
      debugger
    })
  }
}

module.exports = LienLoad
