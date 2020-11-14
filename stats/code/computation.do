

use build/output/SCF_89_19_cleaned.dta, clear

keep if inrange(age, 25, 45)
keep if (year == 2016)
gen fwgt = round(wgt)
gen x_not_constrained = (x_liquid >= labinc * 3 / 12) & !missing(labinc, x_liquid)
gen x_budgeting_horizon = budgeting_horizon
label define xbh_lbl 1 "Few months" 2 "One Year" 3 "Few years" 4 "5-10 years" 5 ">10 years"
label values x_budgeting_horizon xbh_lbl

* Quantiles of labor income
xtile x_labinc_quantile = labinc if (labinc > 10000) & !missing(labinc), nquantiles(5)
label variable x_labinc_quantile "Labor income quantile"

************************************************
* Check dependence of stock exposure on income
gen log_income = log(income)
corr x_stockexp log_income [fw=fwgt]


* Appears to be a boundary condition where people choose no stock exposure
* Does this vary by demographics or education?
* What role does stock aversion have on the distribution of wealth? On HtM behavior?
* Need a risky asset and a safe asset

#delimit ;
histogram x_stockexp [fw=fwgt] if x_liquid > 10000, fraction
	graphregion(color(white));
#delimit cr
// gen x_cond_stockexp = (x_stockexp > 0) & !missing(x_stockexp)


gen exclusion = (anticipates_expenses == 1) & (saving_for_expense == 1)
replace exclusion = 1 if (budgeting_horizon <= 2)
replace exclusion = 1 if (finrisktol == 4)
replace exclusion = 1 if (healthinsured == 0)
replace exclusion = 1 if (x_liquid <= 20000)
replace exclusion = 1 if x_surplusliquid <= 10000
replace exclusion = 1 if !x_not_constrained

#delimit ;
histogram x_stockexp [fw=fwgt] if !exclusion, fraction
	graphregion(color(white));
#delimit cr

* STOCK AVERSE HOUSEHOLDS BY VARIABLE
gen stock_averse = (x_stockexp == 0) if !missing(x_stockexp)
label variable stock_averse "Stock averse"

local byvariables x_labinc_quantile x_budgeting_horizon

foreach var of local byvariables {
	if "`var'" == "x_labinc_quantile" {
		local description "by earnings quintile"
		local fsuffix "earnings_quintile"
	}
	else if "`var'" == "x_budgeting_horizon" {
		local description "by budgeting horizon"
		local fsuffix "budget_horizon"
	}

	#delimit ;
	graph bar (mean) stock_averse [fw=fwgt], over(`var')
		graphregion(color(white))
		ytitle("Share of no-stock households")
		title("No-stock households, `description'");
	#delimit cr
	graph export stats/output/figures/nostock_`fsuffix'.png, replace
}

* WHO ARE THE STOCK-AVERSE HOUSEHOLDS?
gen stock_averse = (x_stockexp == 0) if !missing(x_stockexp) & x_not_constrained

#delimit ;
graph bar (mean) stock_averse [fw=fwgt], over(`byvariable')
	ytitle("Share of stock averse households")
	title("Stock aversion");
#delimit cr



