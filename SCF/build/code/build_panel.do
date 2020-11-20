

use "build/input/panel2009extract.dta", clear

rename WGT09 wgt
rename AGE07 age
rename YY1 hhid
rename Y1 impid

rename STOCKS07 stocks2007
rename STOCKS09 stocks2009
rename HSTOCKS07 hstocks2007
rename HSTOCKS09 hstocks2009
drop stocksdif stockspct

keep wgt age hhid impid stocks* hstocks*

reshape long stocks hstocks, i(impid) j(year)

gen period = 1 if (year == 2007)
replace period = 2 if (year == 2009)

tsset impid period
gen entered_stocks = (hstocks==1) & (L.hstocks==0)
gen left_stocks = (hstocks==0) & (L.hstocks==1)

// keep if inrange(age, 25, 55)

collapse hstocks entered_stocks left_stocks [aw=wgt], by(year)
