*** Read PSID output ***s
use build/output/output.dta, clear
tsset famid period
keep if (nyears >= 6)

*** Gen variables ***
gen income_to_con = earnings / consumption if (consumption > 0) & !missing(consumption)
gen sqage = age ^ 2
gen emergencyfunds = (liquid > (earnings / 12)) if !missing(liquid, income)
gen logc = log(consumption)
gen dcon = D.logc
gen logearn = log(earnings) if earnings > 1000
gen Dlogearn = D.logearn
gen Lemergencyfunds = L.emergencyfunds

replace left_stocks = . if L.has_stocks == 0

*** Estimate model of stock market exit ***
#delimit ;
heckman left_stocks period Dlogearn L.emergencyfunds c.Dlogearn#c.Lemergencyfunds
	c.educ#c.Dlogearn
	[pw=lwgt] if (nofamchange == 1), first
	select(L.has_stocks = L.age L.sqage L.period L2.educ L2.wealth
		L.qreturn L2.qreturn L.areturn L.imort
		L2.has_stocks L2.recdgifts) vce(robust);
#delimit cr

*** Model without Heckman correction ***
probit left_stocks period D.logearn L.emergencyfunds educ homeowner c.educ#c.homeowner if (nofamchange == 1), robust

*** Estimate effect of stock market exit on liquid cash ***
gen liquid_to_earnings = liquid / earnings if (earnings > 1000) & !missing(earnings)
gen cash_to_earnings = cash / earnings if (earnings > 1000)

reg liquid_to_earnings left_stocks [pw=lwgt] if L.has_stocks, robust
