var Workbook;

Workbook = function() {
  if (!(this instanceof Workbook)) {
    return new Workbook;
  }
  this.SheetNames = [];
  this.Sheets = {};
};


class XLSXExport {
  constructor() {
    this.rows = []
    this.options = undefined
    this.wb = new Workbook()
    this.ws_name = 'SheetJS'
    this.document_name = 'test.xlsx'

    this.format_cols = [
      {"width":"17.140625","customWidth":"1","wpx":120,"wch":16.43,"MDW":7},
      {"width":"6","bestFit":"1","customWidth":"1","wpx":42,"wch":5.29,"MDW":7},
      {"width":"5.140625","customWidth":"1","wpx":36,"wch":4.43,"MDW":7},
      {"width":"7.7109375","bestFit":"1","customWidth":"1","wpx":54,"wch":7,"MDW":7},
      {"width":"18.85546875","bestFit":"1","customWidth":"1","wpx":132,"wch":18.14,"MDW":7},
      {"width":"10.42578125","bestFit":"1","customWidth":"1","wpx":73,"wch":9.71,"MDW":7},
      {"width":"25.28515625","bestFit":"1","customWidth":"1","wpx":177,"wch":24.57,"MDW":7},
      {"width":"10.42578125","bestFit":"1","customWidth":"1","wpx":73,"wch":9.71,"MDW":7},
      {"width":"12.7109375","customWidth":"1","wpx":89,"wch":12,"MDW":7},
      {"width":"12.7109375","customWidth":"1","wpx":89,"wch":12,"MDW":7},
      {"width":"12.7109375","customWidth":"1","wpx":89,"wch":12,"MDW":7}
    ].map( (col) => {
      var arr = []
      Object.keys(col).map( (key) => {
        arr[key] = col[key]
      })
      return arr
    })

    //TODO: Styles not working
    this.styles = [
      {"numFmtId":0,"fontId":"0","fillId":0,"borderId":"0","xfId":"0"},
      {"numFmtId":0,"fontId":"2","fillId":0,"borderId":"1","xfId":"0","applyFont":"1","applyFill":"1","applyBorder":"1","applyAlignment":"1"},
      {"numFmtId":0,"fontId":"3","fillId":0,"borderId":"0","xfId":"0","applyFont":"1","applyAlignment":"1"},
      {"numFmtId":0,"fontId":"1","fillId":0,"borderId":"0","xfId":"0","applyFont":"1","applyAlignment":"1"},
      {"numFmtId":0,"fontId":"4","fillId":0,"borderId":"0","xfId":"0","applyFont":"1","applyAlignment":"1"},
      {"numFmtId":0,"fontId":"5","fillId":0,"borderId":"2","xfId":"0","applyFont":"1","applyBorder":"1"},
      {"numFmtId":14,"fontId":"5","fillId":0,"borderId":"2","xfId":"0","applyNumberFormat":"1","applyFont":"1","applyBorder":"1"},
      {"numFmtId":0,"fontId":"0","fillId":0,"borderId":"2","xfId":"0","applyBorder":"1"}
    ]

    this.merge_cells = [{"s":{"c":0,"r":0},"e":{"c":10,"r":0}}]
  }

  createWorksheet() {
    this.ws = convert_to_xlsx_json(this.rows, this.options)
    this.wb.SheetNames.push( this.ws_name )
    this.wb.Sheets[this.ws_name] = this.ws

    this.ws['!cols'] = this.format_cols
    // this.ws['!merges'] = this.merge_cells
    this.wb.Styles = {CellXf: this.styles}
  }

  addRow(row) {
    var filtered_row = row.map( (val) => {
      return (val || "").toString()
    })
    this.rows.push(filtered_row)
  }

  s2ab(s) {
    var buf, i, view;
    buf = new ArrayBuffer(s.length);
    view = new Uint8Array(buf);
    i = 0;
    while (i !== s.length) {
      view[i] = s.charCodeAt(i) & 0xFF;
      ++i;
    }
    return buf;
  }

  save() {
    var s2ab;
    this.createWorksheet()
    var wbout = XLSX.write(this.wb, {
      bookType: 'xlsx',
      bookSST: true,
      type: 'binary'
    })

    saveAs(new Blob([this.s2ab(wbout)], {
      type: 'application/octet-stream'
    }), this.document_name);
  }
}

var convert_to_xlsx_json, datenum;

datenum = function(v, date1904) {
  var epoch;
  if (date1904) {
    v += 1462;
  }
  epoch = Date.parse(v);
  return (epoch - (new Date(Date.UTC(1899, 11, 30)))) / (24 * 60 * 60 * 1000);
};

convert_to_xlsx_json = function(data, opts) {
  var ws;
  var C, R, cell, cell_ref, range, ws;
  ws = {};
  range = {
    s: {
      c: 10000000,
      r: 10000000
    },
    e: {
      c: 0,
      r: 0
    }
  };
  R = 0;
  while (R !== data.length) {
    C = 0;
    while (C !== data[R].length) {
      if (range.s.r > R) {
        range.s.r = R;
      }
      if (range.s.c > C) {
        range.s.c = C;
      }
      if (range.e.r < R) {
        range.e.r = R;
      }
      if (range.e.c < C) {
        range.e.c = C;
      }
      cell = {
        v: data[R][C]
      };
      if (cell.v === null) {
        ++C;
        continue;
      }
      cell_ref = XLSX.utils.encode_cell({
        c: C,
        r: R
      });
      if (typeof cell.v === 'number') {
        cell.t = 'n';
      } else if (typeof cell.v === 'boolean') {
        cell.t = 'b';
      } else if (cell.v instanceof Date) {
        cell.t = 'n';
        cell.z = XLSX.SSF._table[14];
        cell.v = datenum(cell.v);
      } else {
        cell.t = 's';
      }
      if (R < 3) {
        cell.h = cell.v;
        cell.w = cell.v;
        cell.r = "<t>" + cell.v + "</t>";
      }
      ws[cell_ref] = cell;
      ++C;
    }
    ++R;
  }
  if (range.s.c < 10000000) {
    ws['!ref'] = XLSX.utils.encode_range(range);
  }
  return ws;
};

module.exports = XLSXExport
