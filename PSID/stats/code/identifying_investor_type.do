*** Read PSID output ***s
use build/output/output.dta, clear
tsset famid period
keep if (nyears >= 10)

*** Likelihood of being an investor ***
gen stockholder = 1 if inlist(investortype, 1, 2)
replace stockholder = 0 if (investortype == 0)
gen yrseduc1999 = educ if (year == 1999)
gen logearn1999 = log(earnings) if (year == 1999) & (earnings > 1000)
gen wquintile1999 = quint_wealth if (year == 1999)
gen age2017 = ageh if (year == 2017)
gen home1999 = homeowner if (year == 1999)
gen wgts = lwgt if (year == 2017)

collapse stockholder yrseduc1999 logearn1999 wquintile1999 age2017 home1999 wgts, by(famid)

#delimit ;
probit stockholder yrseduc1999 logearn1999 wquintile1999 age2017 home1999
	[pw=wgts], robust;
#delimit cr

margins, dydx(yrseduc1999 logearn1999)
predict yhat_wq_low if (wquintile1999 == 4)

replace wquintile1999 = wquintile1999 + 1
predict yhat_wq_high

gen effect_wealthquintile = yhat_wq_high - yhat_wq_low
sum effect_wealthquintile [aw=wgts]


*** Likelihood of being a buy-and-hold investor ***
gen buyandhold = 1 if (investortype == 2)
replace buyandhold = 0 if (investortype == 1)

gen yrseduc1999 = educ if (year == 1999)
gen logearn1999 = log(earnings) if (year == 1999) & (earnings > 1000)
gen wquintile1999 = quint_wealth if (year == 1999)
gen age2017 = ageh if (year == 2017)
gen home1999 = homeowner if (year == 1999)
gen wgts = lwgt if (year == 2017)

collapse buyandhold yrseduc1999 logearn1999 wquintile1999 age2017 home1999 wgts, by(famid)

#delimit ;
probit buyandhold yrseduc1999 logearn1999 wquintile1999 age2017 home1999
	[pw=wgts], robust;
#delimit cr

margins, dydx(yrseduc1999 wquintile1999)
