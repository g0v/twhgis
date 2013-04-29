# prepare ivid-based csv.  for example, with national population census data:
# iconv -f big5-2003 -t utf-8 /tmp/U01VI_101Y9M_TW.csv | lsc prepare.ls --villages ./out/villages-2010-12-25.json --column household=fld0101 --column male=fld0301 --column female=fld0401 > census2012-09.csv
require! <[csv optimist fs]>
villages = require optimist.argv.villages
column = optimist.argv.column
throw 'must specify columns' unless column
column = [column] unless Array.isArray column

columns = do
    id: \V_ID
    county: \COUNTY_ID_NM
    town: \TOWN_ID_NM
    village: \V_ID_NM

defaults = {[k, v] for k, v of columns}

for c in column
    [k,v] = c.split '='
    columns[k] = v ? k

var by-name-cache
by-name = (ctv) ->
    by-name-cache ?:= {[v<[county town name]>.join(\-), v] for _, v of villages}
    by-name-cache[ ctv.join \- ]

console.log (['ivid'] ++ [h for h of columns when !defaults[h]]).join \,
var header
seen = {}
<- csv!from.stream process.stdin
.on \record (row,index) ->
    if index is 0
        header := row
    else if index > 1
        entry = {[header[i], row[i]] for i of row}
        id = entry[columns.id]
        ctv = columns<[county town village]>.map -> entry[it]
        ctv.0 .= replace /台/, \臺
        v = if id => villages[id] else by-name ctv
        if v
            seen[v.ivid] = true
            console.log ([v.ivid] ++ [entry[h] for name, h of columns when !defaults[name]]).join \,
        else
            console.error ctv.join \,
.on \end

for id, {ivid}:v of villages when !seen[ivid]
    console.error \NOTFOUND v<[ivid county town name]>

#console.log seen
