*** Read PSID output ***s
use build/output/output.dta, clear
tsset famid period

keep if (nyears >= 6)

*** Gen variables ***
gen income_to_con = earnings / consumption if (consumption > 0) & !missing(consumption)
gen sqage = age ^ 2
gen emergencyfunds = (liquid > (earnings / 12)) if !missing(liquid, income)
gen logc = log(consumption)
gen logearn = log(earnings) if earnings > 1000


*** Estimate cash effect of stock sales ***
gen lagemergencyfunds = L.emergencyfunds
gen lagstocks = L.stocks
reg D.cash D.consumption D.earnings c.lagemergencyfunds#c.lagstocks lagstocks [aw=lwgt] if left_stocks == 1, robust

gen dcash = D.cash / lagstocks if L.has_stocks == 1

// #delimit ;
// heckman dcash lagstocks lagemergencyfunds c.lagstocks#c.lagemergencyfunds [pw=lwgt] if has_stocks == 0, first
// 	select(L.has_stocks = L.educ L.age) vce(robust);
// #delimit cr

collapse (median) dcash [aw=lwgt] if left_stocks == 1, by(lagemergencyfunds)
br

* Households with ample emergency funds don't vary their cash holdings when selling stock
* so they are not liquidity constrained households trying to raise funds. Households
* without emergency funds increase cash holdings, but only by about 25% of the
* stock sale-->maybe they overcompensate when raising liquidity? Or liquidity
* was just so low to begin with? Fixed cost of stock ownership?
* Try probit model with a fixed disutility of stock ownership.
