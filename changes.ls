# turn http://ethercalc.org/_/g0v-admin-changes/csv into changes.json
require! <[csv optimist fs]>
changes = []
var header
<- csv!from.stream fs.createReadStream \./raw/g0v-admin-changes.csv
.on \record (row,index) ->
    return unless index
    if index is 1
        header := row
    else
        entry = {[header[i], row[i]] for i of row}
        if entry.date
            entry.date = new Date 1900, 0, -1 .getTime! + entry.date * 1000ms * 3600sec * 24hr

        entry.action = match entry.action
        | \刪 => \D
        | \增 => \C
        | \修 => \U
        else => console.log entry; entry.action
        match entry.action
        | \D
            if entry.new is /\S/
                console.log entry
                throw \D
            unless [_, village, others]? = entry.old.match /(\S+)\s*(?:[（(]併入(\S+)[）)])?/
                console.log entry
                throw \D
            entry.village = village
            entry.others = others?split /及|、/
        | \C
            if entry.old is /\S/
                console.log entry
                throw \D
            unless [_, village, others]? = entry.new.match /(\S+)\s*(?:[（(]由(\S+)分割[）)])?/
                console.log entry
                throw \D
            entry.village = village
            entry.others = others?split /及|、/
        | \U
            entry.village = entry.new
            entry.others = entry.old

        entry.date ||= changes[*-1].date
        if entry.vid.substr(0,1) is \6
            [_, tid, cid, vid]? = entry.vid.match /^(\d\d)0(\d\d\d)0-(\d\d\d)$/
            console.error entry.vid unless tid
            throw entry.vid unless tid
            entry.vid = "#{tid}000#{cid}-#{vid}"
        else
            entry.vid.=replace /^(\d+)/, '$10'
        changes.push entry{county, town, vid, action, date, village, others}
.on \end
#set = require \./test.json #\./raw/tw-2013-03
console.log JSON.stringify changes , null ,4
#villages = require \./villages
