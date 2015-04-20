all: changes.json KHH-2010.json TNN-2010.json TXG-2010.json TPQ-2010.json

changes.json: raw/g0v-admin-changes.csv
	lsc changes.ls > changes.json

KHH-2010.json: raw/KHH-2010-changes.csv
	lsc tchanges.ls --date='2010-12-25' $< > $@

TNN-2010.json: raw/TNN-2010-changes.csv
	lsc tchanges.ls --date='2010-12-25' $< > $@

TXG-2010.json: raw/TXG-2010-changes.csv
	lsc tchanges.ls --date='2010-12-25' $< > $@

TPQ-2010.json: raw/TPQ-2010-changes.csv
	lsc tchanges.ls --date='2010-12-25' $< > $@

TAO-2014.json: raw/TAO-2014-changes.csv
	lsc tchanges.ls --date='2014-12-25' $< > $@

build:
	lsc walk.ls ./*-2010.json ./*-2014.json
	rm -rf villages; perl format.pl

push:
	cd villages && git remote add origin git@github.com:g0v/twhgis.git && git push origin master:latest -f --tags
