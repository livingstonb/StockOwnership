*** Read ***
use "build/output/annual_hh.dta", clear

gen istocks = val_st + val_mf
gen ihas_stocks = (istocks > 0) if !missing(istocks)

bysort ssuid swave: egen stocks = total(istocks), missing
bysort ssuid swave: egen has_stocks = total(ihas_stocks), missing
duplicates drop ssuid swave, force

tsset ssuid swave
by ssuid: egen yrstocks = total(has_stocks)
by ssuid: gen nyrs = count(has_stocks)
gen always_in = (yrstocks == nyrs)


collapse (mean) always_in has_stocks [aw=swgts], by(swave)
