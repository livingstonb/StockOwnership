*** Read ***
use build/output/output.dta, clear
tsset famid period

keep if inrange(25, 55)

*** Statistics ***
sum largepurchase [aw=lwgt] if (left_stocks==1)
collapse (sum) left_stocks [aw=lwgt] if (nyears >= 6), by(largepurchase)
br

*** Switch ***
// gen entryexit = (L2.has_stocks == 1) & (L.has_stocks == 0) & (has_stocks == 1)
gen entryexit = (L2.wostock == 1) & (L.wostock == 0) & (wostock == 1)
by famid: egen possible_outlier = max(entryexit)

sort famid period
count if possible_outlier








gen entry = (L.wostock == 0) & (wostock == 1)
gen exit = (L.wostock == 1) & (wostock == 0)

collapse (mean) wostock (mean) entry (mean) exit [aw=lwgt] if (nofamchange == 1)
br
