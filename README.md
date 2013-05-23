historical geographic information data for Taiwan
=================================================

To download individual version of administrative division: https://github.com/g0v/twhgis/tags

Discussion: https://hackpad.com/gOc6ibdldTC

# Data Source
* http://www.dgbas.gov.tw/ct.asp?xItem=951&ctNode=5485 - official list of codes (pdf) and changes (doc)
* https://ethercalc.org/g0v-admin-changes - data cleanup for revision log from dgbas

# Rebuild

	% npm i
	% cpanm File::chdir JSON
	% make build

# Todo

* cover all changes in g0v-admin-changes (fix dates)
* incorporate border changes
* find more ancient borders


# CC0 1.0 Universal

To the extent possible under law, Chia-liang Kao has waived all copyright
and related or neighboring rights to twhgis

This work is published from Taiwan.

http://creativecommons.org/publicdomain/zero/1.0
