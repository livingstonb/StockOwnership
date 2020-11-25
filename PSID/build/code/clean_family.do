use "build/output/cleaned.dta", clear
// gen suid = group(famid personid)

keep if year >= 1999
keep if (famchange == 0) | (year == 1999)

keep if inrange(year, 1999, 2001)

egen suid = group(famid personid)
bysort famid intid: egen newid = max(suid)

collapse (sum) stocks (sum) soldstock (sum) lwgt, by(newid year)

gen has_stocks = (stocks > 0) & !missing(stocks)
gen period = (year - 1997) / 2

tsset newid period
gen st01 = (L.has_stocks == 0) & (has_stocks == 1) if !missing(L.has_stocks, has_stocks)
gen st10 = (L.has_stocks == 1) & (has_stocks == 0) if !missing(L.has_stocks, has_stocks)

collapse has_stocks entered=st01 left=st10 [aw=lwgt], by(year)
br
