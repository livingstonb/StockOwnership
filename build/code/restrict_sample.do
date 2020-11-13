

use build/output/SCF_89_19_cleaned.dta, clear

keep if inrange(age, 25, 45)
gen fwgt = round(wgt)

* All savings that can be easily adjusted (or that people commonly adjust)
gen x_savings = liq + cds + nmmf + stocks + bond
gen x_risky = stmutf + comutf + stocks
gen x_stock_exposure = x_risky / x_savings if x_savings > 0

* Check dependence of stock exposure on income
gen log_income = log(income)
corr x_stock_exposure log_income [fw=fwgt]

* Appears to be a boundary condition where people choose no stock exposure
* Does this vary by demographics or education?
* What role does stock aversion have on the distribution of wealth? On HtM behavior?
* Need a risky asset and a safe asset

#delimit ;
histogram x_stock_exposure [fw=fwgt] if x_savings > 10000, fraction
	bgcolor(white);
#delimit cr
gen x_has_stock_exposure = (x_stock_exposure > 0) & !missing(x_stock_exposure)
