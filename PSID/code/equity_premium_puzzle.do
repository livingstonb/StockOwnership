use build/output/output.dta, clear

merge m:1 year month using "../SurveyOfConsumers/build/output/stocks_tr.dta", nogen keep(1 3)

tsset famid period

gen congrowth = log(consumption) - log(L.consumption)
gen earngrowth = (earnings - L.earnings) / L.earnings if (L.earnings >= 10000)
tabstat congrowth [aw=lwgt], statistics(sd)

keep if year >= 1999
gen sqageh = ageh ^ 2


* Test if consumption growth falls with stock market exit
gen had_stocks = (L.has_stocks == 1)
reg congrowth left_stocks ageh sqageh earngrowth educ if had_stocks [aw=lwgt], robust

* Test if liquid assets falls with stock market exit
gen liqgrowth = (liquid - L.liquid) / L.liquid if (L.liquid >= 1000)
reg liqgrowth left_stocks ageh sqageh earngrowth educ if had_stocks [aw=lwgt], robust

* Test if consumption growth rises with stock market entry
gen had_no_stocks = (L.has_stocks == 0)
reg congrowth entered_stocks ageh sqageh earngrowth educ if had_no_stocks [aw=lwgt], robust








gen in_sample = has_stocks & L.has_stocks



* Stock market holders
tabstat congrowth [aw=lwgt] if has_stocks & L.has_stocks, statistics(mean sd)
corr congrowth areturn [aw=lwgt] if has_stocks & L.has_stocks

* Stock market leavers
tabstat congrowth [aw=lwgt] if !has_stocks & L.has_stocks, statistics(mean sd)
corr congrowth areturn [aw=lwgt] if !has_stocks & L.has_stocks

* Stock market entrants
tabstat congrowth [aw=lwgt] if has_stocks & !L.has_stocks, statistics(mean sd)
corr congrowth areturn [aw=lwgt] if has_stocks & !L.has_stocks

* Stock market leavers & entrants
tabstat congrowth [aw=lwgt] if (has_stocks & !L.has_stocks) | (!has_stocks & L.has_stocks), statistics(mean sd)
corr congrowth areturn [aw=lwgt] if (has_stocks & !L.has_stocks) | (!has_stocks & L.has_stocks)

* Always in
bysort famid: egen yrstocks = total(has_stocks), missing
tabstat congrowth [aw=lwgt] if (yrstocks >= 4) & !missing(yrstocks), statistics(mean sd)
corr congrowth areturn [aw=lwgt] if (yrstocks >= 4) & !missing(yrstocks)


* 
