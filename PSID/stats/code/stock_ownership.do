

use "build/output/PSID.dta", clear
cap mkdir stats/output

keep if (age>=25) & (age<=45)
drop if labinc < 0

gen has_stocks = (stocks > 0) & !missing(stocks)

collapse (sum) popshare=wgt, by(occupation)
egen poptot = sum(popshare)
replace popshare =  popshare / poptot
