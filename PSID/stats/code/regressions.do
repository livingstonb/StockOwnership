
*** Read Survey of Consumers output ***
use "../SurveyOfConsumers/build/output/cleaned.dta", clear

*** Clean ***
rename YTL5 x_labinc_quintile
rename YYYY year
rename EGRADE educyears
rename AGE age
rename SEX sex

keep if inrange(age, 25, 55)

gen homeowner = (HOMEOWN == 1) if !missing(HOMEOWN)

merge m:1 year month using "../SurveyOfConsumers/build/output/stocks.dta", nogen keep(1 3)

gen sqage = age ^ 2

*** Fit household stock expectations model ***
reg chance_pstock_up age sqage year x_labinc_quintile c.educyears##c.qreturn areturn c.educyears#c.areturn [pw=WT], robust

gen pstock_net = pstock_ge60 - pstock_le40

collapse (mean) pstock_le40 (mean) pstock_ge60 (mean) pstock_net [pw=WT], by(year month)

tempfile stockexpectations
save `stockexpectations'

*** Read PSID output ***
use build/output/output.dta, clear
rename educ educyears
rename ageh age

// merge m:1 year month using "../SurveyOfConsumers/build/output/stocks.dta", nogen keep(1 3)
// merge m:1 year month using `stockexpectations', nogen keep(1 3)

tsset famid period
gen had_no_stocks = l.has_stocks == 0 if !missing(l.has_stocks)
gen had_stocks = l.has_stocks > 0 & !missing(l.has_stocks)
gen sqage = age ^ 2

predict stockexp, xb
replace stockexp = stockexp / 100
replace stockexp = stockexp ^ 2

* Sample selection
keep if x_wealth_quintile == 5

probit entered_stocks homeowner age sqage year educyears x_labinc_quintile stockexp c.educyears#c.stockexp [pw=lwgt] if had_no_stocks, robust

probit has_stocks age sqage homeowner year educyears x_labinc_quintile stockexp pstock_net qreturn areturn [pw=lwgt], robust

probit entered_stocks age sqage homeowner year educyears x_labinc_quintile pstock_net qreturn areturn [pw=lwgt] if had_no_stocks, robust

gen lstockexp = l.stockexp
probit entered_stocks homeowner age sqage year educyears x_labinc_quintile lstockexp c.educyears#c.lstockexp l.pstock_net [pw=lwgt] if had_no_stocks, robust

probit left_stocks homeowner age sqage year educyears x_labinc_quintile stockexp c.educyears#c.stockexp pstock_net [pw=lwgt] if had_stocks, robust

use build/output/output.dta, clear
