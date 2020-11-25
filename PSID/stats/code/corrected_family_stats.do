keep if year >= 1999
gen period =  (year + 1) / 2
// gen nofamchange = (famchange == 0)
keep if inrange(age, 25, 55)

collapse (sum) stocks (sum) lwgt, by(famid period)
gen has_stocks = (stocks > 0) if !missing(stocks)
egen uid = group(famid personid)
tsset uid period
gen entry = (has_stocks == 1) & (L.has_stocks == 0) if !missing(has_stocks, L.has_stocks)
gen exit = (has_stocks == 0) & (L.has_stocks == 1) if !missing(has_stocks, L.has_stocks)
collapse has_stocks entry exit [pw=lwgt], by(period)
