require! <[csv optimist fs mkdirp moment]>
changes = require \./changes.json

var header
villages = {}
<- csv!from.stream fs.createReadStream \../twgeojson/districts.csv
.on \record (row,index) ->
    if index is 0
        header := row
    else
        entry = {[header[i], row[i]] for i of row}
        villages[entry.id] = entry
.on \end

for file in optimist.argv._
    changes ++= require file

write-tree = (dir) ->
    for _, {county,town,name:village}:v of villages
        vdir = "#dir/#county/#town/#village"
        mkdirp.sync vdir
        fs.writeFileSync "#vdir/index.json", JSON.stringify do
            type: village.substr -1, 1
            ivid: v.ivid
            vid: v.vid
        unless fs.existsSync "#dir/#county/#town/index.json"
            fs.writeFileSync "#dir/#county/#town/index.json", JSON.stringify do
                type: v.town.substr -1, 1
                itid: v.itid
                tid: v.vid
        unless fs.existsSync "#dir/#county/index.json"
            fs.writeFileSync "#dir/#countuy/index.json", JSON.stringify do
                type: v.county.substr -1, 1
                icid: v.icid
                cid: v.cid




village-version = new Date 2013, 4-1, 1 .getTime!
stop = new Date 2000, 12-1, 31 .getTime!
#stop = new Date 2010, 12-1, 26
by-dates = {}
for {date}:c in changes when date
    by-dates[date] ?= []
        ..push c
dates = [+d for d of by-dates].sort((a,b)-> a - b).reverse!

# Curried functions using -->
sort-by = (prop, list) --> list.sort (a, b) ->
  | a[prop] > b[prop] => -1
  | a[prop] < b[prop] => 1
  | otherwise         => 0


old3166 = do
  臺北縣: \TPQ
  高雄縣: \KHQ
  高雄市: \KHH
  臺中市: \TXG
  臺中縣: \TXQ
  臺南市: \TNN
  臺南縣: \TNQ
tw3166 = require \../twgeojson/vote/3166-2-tw
populate = (entry) ->

  [_, tid, vid] = entry.id.match /(\d+)-(.*)$/
  cid = tid.substr(0, 5)
  if entry.county-reorg
    [cid,tid] = entry<[cid tid]>
    icid = old3166[entry.county]
    itid = icid + '-' + tid.substr 5, 3
  else
    [icid]? = [[icid] for _, {icid,county} of villages when county is entry.county].0
    itid = icid + '-' + tid.substr 5, 3

  entry <<< {cid, icid, tid, itid, vid, ivid: "#itid-#vid"}

#write-tree \output
for d in dates when stop <= d <= village-version
  ymd = moment d .format 'YYYY-MM-DD'
  console.log \=== d, ymd
  fs.writeFileSync "out/villages-#ymd.json", JSON.stringify villages
  for c in by-dates[d] |> sort-by 'action'
    v = villages[c.vid]
    if c.others
        others = c.others?map ->
            town = c.town
            if it.match /^(.*[鄉鎮市區])(\S{2,}[村里])/
                console.log \==== that
                [town, it] = that[1,2]
            [matched] = [v for id, v of villages when v<[county town name]> === [c.county, town, it]]
            console.log \ERR [c.county, town, it] unless matched
            matched
        .filter -> it
    match c.action
    | \D
        console.log \add c<[vid county town village]>, if others => [\mergeinto others.map (.id)] else null
        villages[c.vid] = populate do
            id: c.vid
            county: c.county
            town: c.town
            name: c.village

        console.log \added villages[c.vid]
    | \C
        unless v
            console.log \ERR c<[county town village]>, \NOTFOUND
            continue
        console.log \remove c.vid, c.village, if others => [\mergeinto others.map (.id)] else null
        delete villages[c.vid]
    | \U
        if entry = c.entry
            current = delete villages[c.vid]
            unless current
                console.log \ERR c.vid
            name = if current.name isnt entry.vname
                entry.ovname -= /？$/
                res = current.name - /.$/ + entry.ovname.substr(-1, 1)
                console.log \+++ v.name, entry.vname, entry.ovname, \==== res
                res
            else
                entry.ovname
            orig = populate do
                id: "#{entry.otid}-#{entry.ovid}"
                tid: entry.otid
                cid: entry.otid.substr(0, 5)
                county: entry.ocounty
                town: entry.otown
                name: name
                county-reorg: true
            villages[orig.id] = orig
            #console.log \U c.vid, \=> orig.id
        else
            console.log \UPDATE c
            if c.vid is /-/
                v.name = c.original
            else
                # town name change, new = village, old = town
                for _, v of villages when v.town is c.village
                    console.log \U v<[town name]>
                    v.town = c.town

fs.writeFileSync "out/villages-00earlier.json", JSON.stringify villages
