
import delimited "build/input/GSPC.csv", clear varnames(1)
rename date strdate
gen ddate = date(strdate, "YMD")
drop strdate
format %td ddate

gen month = month(ddate)
gen year = year(ddate)
gen mdate = ym(year, month)
format %tm mdate

rename close pstock
drop open high low adjclose volume ddate

tsset mdate
gen lpstock = log(l.pstock)
gen qreturn = d.lpstock
gen areturn = s12.lpstock

tempfile stockdata
save `stockdata'
save "build/output/stocks.dta", replace


import delimited "build/input/SP500TR.csv", clear varnames(1)
rename date strdate
gen ddate = date(strdate, "YMD")
drop strdate
format %td ddate

gen month = month(ddate)
gen year = year(ddate)
gen mdate = ym(year, month)
format %tm mdate

rename close pstock
drop open high low adjclose volume ddate

drop if _n == 396
tsset mdate
gen lpstock = log(l.pstock)
gen qreturn = d.lpstock
gen areturn = s12.lpstock

tempfile stockdata
save `stockdata'
save "build/output/stocks_tr.dta", replace


import delimited "build/input/PCE.csv", clear varnames(1)
rename date strdate
gen ddate = date(strdate, "YMD")
drop strdate
format %td ddate

gen month = month(ddate)
gen year = year(ddate)
gen mdate = ym(year, month)
format %tm mdate

drop ddate mdate
save "build/output/pce.dta", replace
