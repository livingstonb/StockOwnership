*** Read PSID output ***s
use build/output/output.dta, clear
tsset famid period
keep if (nyears >= 6)

keep if inrange(ageh, 45, 55)


collapse (mean) has_stocks (mean) L.has_stocks (mean) entered_stocks (mean) left_stocks [aw=lwgt], by(year)
br
