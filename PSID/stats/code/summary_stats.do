*** Read ***
use build/output/output.dta, clear
tsset famid period

*** Bar chart of shockholder share with new/existing/long ***
#delimit ;
graph bar always_holding recently_holding new_entrants [aw=lwgt] if (year > 1999),
	over(year) stack
	legend(label(1 "Always in") label(2 "Recently in") label(3 "New entrants") cols(3)
		region(lstyle(none)))
	graphregion(color(white));
#delimit cr
graph export "stats/output/stockholder_existing_vs_new.png", replace

*** Gross flows ***
#delimit ;
graph bar entered_stocks left_stocks [aw=lwgt] if (year > 1999),
	over(year) legend(label(1 "New entrants") label(2 "Exits")
	region(lstyle(none))) graphregion(color(white));
#delimit cr
graph export "stats/output/gross_flows_psid.png", replace

*** Stockholding by net worth quintile ***
#delimit ;
graph bar has_stocks [aw=lwgt] if (year >= 1999),
	over(quint_wealth) ytitle("Share holding stock")
	legend(label(1 "Bottom") label(5 "Top")
	region(lstyle(none))) graphregion(color(white));
#delimit cr
graph export "stats/output/stocks_by_wealth_quintile.png", replace

*** Stockholding by earnings quintile ***
#delimit ;
graph bar has_stocks [aw=lwgt] if (year >= 1999),
	over(quint_earn) ytitle("Share holding stock")
	legend(label(1 "Bottom") label(5 "Top")
	region(lstyle(none))) graphregion(color(white));
#delimit cr
graph export "stats/output/stocks_by_earnings_quintile.png", replace


*** Median stock share of liquid assets, condl ***
gen always_in_stshare = cond_stshare_liquid if always_holding
gen recently_in_stshare = cond_stshare_liquid if recently_holding
gen new_stshare = cond_stshare_liquid if new_entrants
#delimit ;
graph bar (median) always_in_stshare (median) recently_in_stshare (median) new_stshare [aw=lwgt] if (year > 1999),
	over(year) legend(label(1 "Always in") label(2 "Recently in") label(3 "New entrants") cols(3)
	region(lstyle(none))) graphregion(color(white));
#delimit cr
graph export "stats/output/stock_share_of_liquid.png", replace
