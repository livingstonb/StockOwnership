
use build/output/occ_codes.dta, clear
mkmat censuscode1 censuscode2 censusocc, matrix(occ_codes)
label save censusocc using build/temp/occlbl.do, replace

use build/output/PSID.dta, clear

gen occupation = .

forvalues ii = 1/25 {
	local code1 = occ_codes[`ii',1]
	local code2 = occ_codes[`ii',2]
	local catcode = occ_codes[`ii',3]
	replace occupation = `catcode' if inrange(occhead, `code1', `code2') & (year == 2015)
}

do build/temp/occlbl.do
label values occupation censusocc

clear matrix


//////////////////////

keep if year == 2015
keep if (age>=25) & (age<=45)
drop if labinc < 0

gen fwgt = round(wgt)
xtile qunetworthnc [fw=fwgt], nquantiles(5)

gen has_stocks = (stocks > 0) & !missing(stocks)

collapse (sum) stockholders=wgt if has_stocks & (qunetworthnc == 5), by(occupation)
egen poptot = sum(stockholders)
replace stockholders =  stockholders / poptot
drop poptot


collapse (mean) has_stocks [aw=wgt], by(occupation)
