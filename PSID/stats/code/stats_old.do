clear

use build/output/output.dta

keep if (nyears > 4) & !missing(nyears)

bysort famid: egen yrstocks = sum(has_stocks)
bysort famid: egen tempny = count(has_stocks)
gen always_in_stocks = (yrstocks == tempny) if !missing(has_stocks)
drop yrstocks tempny

collapse (mean) cond_stshare [aw=lwgt], by(year)

local cvars entered_stocks left_stocks has_stocks cond_stshare always_in_stocks

collapse (mean) `cvars' [aw=lwgt], by (year)
br

rename year YYYY
merge 1:1 YYYY using "../SurveyOfConsumers/build/output/stock_expectations.dta", nogen
rename YYYY year

drop if missing(has_stocks)
drop if missing(pstock_le40)

sort year
gen period = _n
tsset period

gen d_has_stocks = d.has_stocks

gen net_stock_exp = pstock_ge60 - pstock_le40
corr net_stock_exp d_has_stocks

//////////////////////////////////
clear

use build/output/output.dta
merge m:1 year month using "../SurveyOfConsumers/build/output/stocks.dta", nogen
rename educ educyears


tsset famid year
predict stockexp, xb
reg entered_stocks age year educyears x_labinc_quintile qreturn areturn stockexp [aw=lwgt] if l.has_stocks == 0, robust
