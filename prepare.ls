# turn http://ethercalc.org/_/g0v-admin-changes/csv into changes.json

# prepare ivid-based csv.  for example, with national population census data:
# iconv -f big5-2003 -t utf-8 /tmp/U01VI_101Y9M_TW.csv | lsc prepare.ls --villages ./out/villages-2010-12-25.json --column household=fld0101 --column male=fld0301 --column female=fld0401 > census2012-09.csv
require! <[csv optimist fs]>
villages = require optimist.argv.villages
column = optimist.argv.column
throw 'must specify columns' unless column
column = [column] unless Array.isArray column

columns = {}
for c in column
    [k,v] = c.split '='
    columns[k] = v
console.error columns
console.log (['ivid'] ++ [h for h of columns]).join \,
var header
seen = {}
<- csv!from.stream process.stdin
.on \record (row,index) ->
    if index is 0
        header := row
    else if index > 1
        entry = {[header[i], row[i]] for i of row}
        unless v = villages[entry.V_ID]
            console.error \unknown entry.V_ID, entry<[TOWN_ID_NM V_ID_NM]>
            throw \z

        seen[v.ivid] = true
        console.log ([v.ivid] ++ [entry[h] for _, h of columns]).join \,
.on \end

for id, {ivid}:v of villages when !seen[ivid]
    console.error \NOTFOUND v<[county town name]>

#console.log seen
