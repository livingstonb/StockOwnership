
use build/temp/fmli2015.dta, clear

keep if inrange(age_ref, 25, 55)

gen stocks = stockx
gen lstocks = stockyrx
// bysort ncuid: egen annstocks = total(stocks), missing
bysort ncuid: gen nyrs = _N
keep if nyrs == 4
collapse (sum) annstocks=stocks (sum) lannstocks=lstocks (sum) popwt (sum) finlwt21, by(ncuid)

gen has_stocks = annstocks > 0 & !missing(annstocks)
gen lhas_stocks = lannstocks > 0 & !missing(lannstocks)
gen left_stocks = (lhas_stocks == 1) & (has_stocks == 0)
gen entered_stocks = (lhas_stocks == 0) & (has_stocks == 1)

collapse (mean) has_stocks (mean) lhas_stocks (mean) left_stocks (mean) entered_stocks [aw=popwt]

sum has_stocks [aw=popwt]



keep if inrange(age, 25, 55)
keep if inrange(year, 2001, 2012)

replace stocks = 0 if missing(stocks)
gen has_stocks = (stocks > 0) if !missing(stocks)

collapse (mean) has_stocks [aw=wtrep01], by(year)

sort id YQ
order id YQ
br
