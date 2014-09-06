require! <[csv optimist fs mkdirp moment]>
changes = require \./changes.json

var header
villages = {}
<- csv!from.stream fs.createReadStream \villages-base.csv
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




village-version = new Date 2015, 1-1, 1 .getTime!
stop = new Date 2000, 12-1, 31 .getTime!
#stop = new Date 2010, 12-1, 26
by-dates = {}
for {date}:c in changes when date
    by-dates[date] ?= []
        ..push c
dates = [+d for d of by-dates].sort (a,b)-> a - b

# Curried functions using -->
sort-by = (prop, list) --> list.sort (a, b) ->
  | a[prop] > b[prop] => -1
  | a[prop] < b[prop] => 1
  | otherwise         => 0


tw3166 = do
  彰化縣: \CHA
  嘉義市: \CYI
  嘉義縣: \CYQ
  新竹縣: \HSQ
  新竹市: \HSZ
  花蓮縣: \HUA
  宜蘭縣: \ILA
  金門縣: \JME
  基隆市: \KEE
  高雄市: \KHH
  連江縣: \LJF
  苗栗縣: \MIA
  南投縣: \NAN
  澎湖縣: \PEN
  屏東縣: \PIF
  桃園市: \TAO
  臺南市: \TNN
  臺北市: \TPE
  新北市: \TPQ
  臺東縣: \TTT
  臺中市: \TXG
  雲林縣: \YUN
tw3166-old = do
  臺北縣: \TPQ
  高雄縣: \KHQ
  高雄市: \KHH
  臺中市: \TXG
  臺中縣: \TXQ
  臺南市: \TNN
  臺南縣: \TNQ
tw3166-reorg = do
  臺北縣: \新北市
  高雄縣: \高雄市
  臺中縣: \臺中市
  臺南縣: \臺南市
  桃園縣: \桃園市


populate = (entry) ->
  [_, tid, vid] = entry.id.match /(\d+)-(.*)$/
  cid = tid.substr(0, 5)
  if entry.county-reorg
    [cid,tid] = entry<[cid tid]>
    county = tw3166-reorg[entry.county] ? entry.county
    icid = tw3166[county]
    itid = icid + '-' + tid.substr 5, 3
    delete entry.county-reorg
  else
    [icid]? = [[icid] for _, {icid,county} of villages when county is entry.county].0
    itid = icid + '-' + tid.substr 5, 3

  entry <<< {cid, icid, tid, itid, vid, ivid: "#itid-#vid"}

fs.writeFileSync "out/villages-00earlier.json", JSON.stringify villages
#write-tree \output
for d in dates when stop <= d <= village-version
  ymd = moment d .format 'YYYY-MM-DD'
  console.log \=== d, ymd
  for c in by-dates[d] |> sort-by 'action'
    v-entry = villages[c.vid]
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
    | \C
        console.log \add c<[vid county town village]>, if others => [\splitfrom others.map (.id)] else null
        villages[c.vid] = populate do
            id: c.vid
            county: c.county
            town: c.town
            name: c.village

        console.log \added villages[c.vid]
    | \D
        unless v-entry
            console.log \ERR c<[county town village]>, \NOTFOUND
            continue
        console.log \remove c.vid, c.village, if others => [\mergeinto others.map (.id)] else null
        delete villages[c.vid]
    | \U
        if entry = c.entry # county reorg
            current = delete villages[ entry<[otid ovid]>.join '-']
            unless current
                console.log \ERR c, entry.ovid
            name = entry.vname
            next-entry = populate do
                id: "#{entry.tid}-#{entry.vid}"
                tid: entry.tid
                cid: entry.tid.substr(0, 5)
                county: c.county
                town: c.town
                name: name
                county-reorg: true
            villages[next-entry.id] = next-entry
            #console.log \U c.vid, \=> orig.id
        else
            console.log \UPDATE c, v-entry
            if c.vid is /-/
                v-entry.name = c.village
            else
                console.log "townchange #{c.town} => #{c.village}"
                # town name change, new = village, old = town
                for _, v of villages when v.town is c.town
                    console.log \U v<[town name]>
                    v.town = c.village
  fs.writeFileSync "out/villages-#ymd.json", JSON.stringify villages
