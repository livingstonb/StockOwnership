use build/output/SCF_89_19_cleaned.dta, clear
keep if inrange(age, 25, 55)

do stats/code/gen_portfolio_variables.do



tabstat x_stock_share_of_risky [fw=fwgt] if x_stock_share_of_risky > 0, by(year) statistics(mean)

keep if inrange(age, 25, 30)
gen has_install_loan = (install > 0) & !missing(install)
tabstat has_stocks [fw=fwgt] if has_install_loan, by(year) statistics(mean)
