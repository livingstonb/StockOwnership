
clear
import delimited "build/input/spy_options.csv", varnames(nonames) rowrange(2)
rename v1 L
rename v2 r

* Drop observations that had trades on the given day
drop if _n == 18
drop if _n == 6

label variable r "Implied borrowing rate"
label variable L "Leverage = assets {&frasl} equity"

#delimit ;
twoway scatter r L,
	graphregion(color(white));
#delimit cr

graph export "stats/output/figures/spy_option_rates.eps", replace
