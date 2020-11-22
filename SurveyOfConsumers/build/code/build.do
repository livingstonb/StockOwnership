
clear

do "build/input/clean_raw.do"

gen has_stocks = (INVEST == 1) if !missing(INVEST)
gen month = YYYYMM - YYYY * 100
rename PSTK chance_pstock_up

gen pstock_le20 = (chance_pstock_up <= 20) if !missing(chance_pstock_up)
gen pstock_le40 = (chance_pstock_up <= 40) if !missing(chance_pstock_up)
gen pstock_ge60 = (chance_pstock_up >= 60) if !missing(chance_pstock_up)
gen pstock_ge80 = (chance_pstock_up >= 80) if !missing(chance_pstock_up)

save "build/output/cleaned.dta", replace





use "build/output/cleaned.dta", clear

collapse (mean) pstock_le40 (mean) pstock_ge60 [aw=WT] if inrange(AGE, 25, 55),by(YYYY)
drop if YYYY < 2002
save "build/output/stock_expectations.dta", replace



label variable YYYY "Year"
#delimit ;
twoway (scatter pstock_le40 YYYY) (scatter pstock_ge60 YYYY) if (YYYY >= 2002),
	legend(label(1 "Pessimistic") label(2 "Optimistic") region(lstyle(none)))
	graphregion(color(white)) ytitle("Share of respondents");
#delimit cr
graph export "stats/output/stock_expectations.png", replace

sum has_stocks [aw=WT] if inrange(AGE, 25, 55) & (YYYY >= 2000) & (month == 1), detail
