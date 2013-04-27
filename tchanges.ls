# turn 2010 county changes into individual json
require! <[optimist csv fs]>
[file] = optimist.argv._
date = new Date(optimist.argv.date).getTime!
var header
changes = []
<- csv {+header} .from.stream fs.createReadStream file
.on \record (row,index) ->
    return unless row.0
    if index is 0
        header := row
    else
        entry = {[header[i], row[i]] for i of row}
        entry.tname -= /第(一|二|三|四)$/
        entry.otname -= /第(一|二|三|四)$/
        entry.tid.=replace /[1-9]$/, \0
        entry.otid.=replace /[1-9]$/, \0
        entry.vid.=replace /[1-9]-/, \0-
        [_, county, town] = entry.tname.match /^(.*?[縣市])(.*)$/
        [_, entry.ocounty, entry.otown] = entry.otname.match /^(.*?[縣市])(.*)$/
        changes.push {date, action: \U, vid: "#{entry.tid}-#{entry.vid}", county, town, village: entry.vname, entry}
.on \end
console.log JSON.stringify changes, null, 4
