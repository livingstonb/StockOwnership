clear


// Code originally written by Justin Weidner


///////////////////////////////////////////////////////////////////////////////
// grabs relevant data from the full data set. See SCF codebooks for the exact
// wording of the questions

cd ${basedir}/build/temp

use year Y1 YY1 X432 X413 X421 X424 X427 X430 X7132 ///
	   X410 X7973 X7976 ///
	   X816 X3010 X7186 X3008 X3015 X3016 X3017 X3018 X3019 X3020 ///
	   X414 X407 X409 ///
	   X5702 X5704 X5716 X5718 X5720 X5722 X5724 X5725 ///
	   X4135 X4206 X4219 X4735 X4806 X4819 ///
	   X7509 X7510 X7054 ///
	   X4112 X4113 X4712 X4713 X4131 X4132 X4731 X4732 ///
	   X411 X425 X7187 X7558 X7559 X7560 ///
	   X5727 X5726 X3014 ///
	   X7402 X7412 X1215 X1216 ///
	   X7401 X7411 ///
	   X7126 X6357 X3923 ///
	   X6809 X6797 X6798 ///
	   X521 X602 X612 X619 X708 X703 X721 X808 X908 X1008 X1039 X1109 X1120 X1131 ///
	   X1210 X1220 X1718 X1818 X2007 X2017 X2105 X2112 X2117 X2213 X2313 X2413 X7162 ///
	   X2425 X2514 X2614 X2626 X7815 X7838 X7861 X7915 X7938 X7938 X7961 X7180 X2718 ///
	   X2735 X2818 X2835 X2818 X2835 X2918 X2935 X7184 X4011 X11028 X11128 X11328 X11428 ///
	   X522 X603 X613 X620 X709 X704 X722 X809 X909 X1009 X7567 X1110 X1121 X1132 X7565 ///
	   X1221 X1719 X1819 X2008 X2018 X2106 X2113 X2118 X7537 X7536 X7535 X7163 X2426 ///
	   X7531 X7530 X2627 X7816 X7839 X7862 X7916 X7939 X7962 X7181 X7527 X7526 X7525 ///
	   X7524 X7523 X7522 X7185 X4012 X11029 X11129 X11329 X11429 ///
	   X1918 X1919 X11528 X11529 X5732 X5734 X7508 X4100 X4700 X4022 X4026 X4030 X7131 X7362 ///
	   X7650 X7372 X108 X114 X120 X126 X132 X202 X208 X214 X220 X226 X8023 X1104 X1115 X1126 ///
	   X816 X916 X1016 X1045 X1111 X1122 X1133 X1216 X2219 X2319 X2419 X7170 ///
		X2520 X2520 X2620 X7822 X7845 X7868 X7922 X7945 X7968 X2724 X2741 X2824 ///
		X2841 X2924 X2941 X4013 X1826 X1726 X1216 ///
		X6551 X6552 X6553 X6554 X6559 X6560 X6561 X6562 X6567 X6568 X6569 X6570 ///
		X6556 X6564 X6572 X6582 X6592 ///
	   using SCF_89_19_full.dta

///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// renames or defines variables in the full data set

label define yesnolabel 0 "No" 1 "Yes"

// race
gen race = X6809

// industry
gen industry = X7402
gen industrysp = X7412

// HELOC limit
gen heloc_lim = X1104 + X1115 + X1126
replace heloc_lim = 0 if heloc_lim < 0

// miscellaneous other assets
gen misc_illiq = X4022 + X4026 + X4030

// head unemployed
gen unemp1 = (X4100 == 30 | X4100 == 16)
// spouse unemployed
gen unemp2 = (X4700 == 30 | X4700 == 16)

// head employed
gen emp1 = (X4100 <= 15)
// spouse empolyed
gen emp2 = (X4700 <= 15) 

// at least one member unemployed
gen unemp = (unemp1 == 1 | unemp2 == 1)

// whether or not the household has credit cards
rename X410 hascc
rename X7973 hasmcvisa
replace hasmcvisa = 1 if X411 > 0 & year <= 1992  // 89 and 92 only ask number of cards
rename X7976 hasamex
replace hasamex = 1 if X425 > 0 & year <= 1992 // 89 and 92 only ask number of cards
replace hascc=0 if (hascc==5 | (hasmcvisa==5 & hasamex==5))  
rename X432  payfreq
rename X413 revbalance1 
rename X421 revbalance2 
rename X424 revbalance3 
replace revbalance3 = 0 if year == 2010 // 2010 absorbed gas station and store cards into X430
rename X427 revbalance4
rename X430 revbalance5

// fix data for 2013-2016
replace revbalance3 = 0 if revbalance3==.
replace revbalance5 = 0 if revbalance5==.


// credit card debt as the sum of all revolving balances on cards
gen ccdebt=0
replace ccdebt = (revbalance1+revbalance2+revbalance3+revbalance4+revbalance5)

// credit limit
rename X414  maxcredit
replace maxcredit=0 if maxcredit==-1

// mortgage
rename X7054 mortrate

// generating income 
rename X5702 hh_earnings
rename X5704 hh_selfy
rename X5716 uiben
rename X5718 childben
rename X5720 tanf
rename X5722 ssinc
rename X5725 source_othinc
rename X5724 othinc
rename X5727 source_othinc2 // 89 and 92 had a second category for other income
rename X5726 othinc2

replace othinc2 = 0 if year >= 1995
// sets income to zero if not regular or asset related
replace othinc=0 if othinc==-1 | source_othinc ==11 | source_othinc ==14 | source_othinc ==30 | source_othinc ==36
replace othinc2=0 if othinc2==-1 | source_othinc2 ==11 | source_othinc2 ==14 | source_othinc2 ==30 | source_othinc2 ==36
replace othinc = othinc + othinc2

// labor income + benefits
gen labinc = hh_earnings+uiben+childben+tanf+ssinc+othinc
// labor income + self employment income
gen labincplus = hh_earnings+hh_selfy+uiben+childben+tanf+ssinc+othinc

rename X7362 usuallabinc
gen inchigh = (X7650 == 1)
gen inclow = (X7650 == 2)
// replaces usual income with the actual income if they say its normal
replace usuallabinc = labinc if X7650 == 3


// direct questions
gen nosavebor = X3015
gen nosavezero = X3016
gen savewhatta = X3017
gen htm1=0
replace htm1 = 1 if nosavebor==1 | nosavezero==1 

rename X7510 spendmorey
rename X7509 buyhome
rename X7508 spendexceedy

gen htm5 = .
replace htm5 = 0 if spendmorey == 3
replace htm5 = 1 if (spendmorey==1 | spendmorey==2) & (buyhome==5 | buyhome == 0)
replace htm5 = 1 if (spendmorey==1 | spendmorey==2) & buyhome==1 & (spendexceedy == 1 | spendexceedy == 2)
replace htm5 = 0 if (spendmorey==1 | spendmorey==2) & buyhome==1 & (spendexceedy == 3 | spendexceedy == 0)

// committed consumption: any regularly occurring bulk payment
// converted to monthly payments

// replace code with number of payments per month
local freqlist X522 X603 X613 X620 X709 X704 X722 X809 X909 X1009 X7567 X1110 X1121 X1132 X7565 ///
	   X1221 X1719 X1819 X2008 X2018 X2106 X2113 X2118 X7537 X7536 X7535 X7163 X2426 ///
	   X7531 X7530 X2627 X7816 X7839 X7862 X7916 X7939 X7962 X7181 X7527 X7526 X7525 ///
	   X7524 X7523 X7522 X7185 X4012 X11029 X11129 X11329 X11429 X1919 X11529

foreach k of local freqlist {
replace `k' = 30 if `k' == 1
replace `k' = 4 if `k' == 2
replace `k' = 2 if `k' == 3
replace `k' = 1 if `k' == 4
replace `k' = 1/3 if `k' == 5
replace `k' = 1/12 if `k' == 6
replace `k' = 1/6 if `k' == 11
replace `k' = .5 if `k' == 12
replace `k' = 2 if `k' == 31

// changes to zero if a one time or variable payment
replace `k' = 0 if `k' <= 0 | (`k' > 6 & `k' < 11) | (`k' > 12 & `k' < 31) | `k' > 31
}

gen rentpmt = X521*X522 + X602*X603 + X612*X613 + X619*X620 + X708*X709 + X703*X704 + X721*X722

// found 5 observations in 1992 that were coded as .d
replace X1220 = 0 if X1220 == .d
gen homeloanpmt = X808*X809 + X908*X909 + X1008*X1009 + X1109*X1110 + X1120*X1121 ///
+ X1131*X1132 + X1718*X1719 + X1818*X1819 + X2007*X2008
//1989 specifically said "What were the monthly payments?" for the home equity loans
replace homeloanpmt = homeloanpmt + X1039*X7567 + X1210*X7565 + X1220*X1221 if year >= 1992
replace homeloanpmt = homeloanpmt + X1039 + X1210 + X1220 if year == 1989
//2010 dropped the third vacation house
replace homeloanpmt = homeloanpmt + X1918*X1919 if year <= 2007

// specifically asked about monthly payments on car notes in 1989 and 1992
gen carpmt = X2105*X2106 + X2112*X2113 + X2117*X2118 + X2213*X7537 + X2313*X7536 + X2413*X7535 ///
+ X7162*X7163 + X2425*X2426 + X2514*X7531 + X2626*X2627 if year >= 1995
replace carpmt = X2105 + X2112 + X2117 + X2213 + X2313 + X2413 + X2425 + X2514 + X2626 if year <= 1992

// 1989 education payments are absorbed into consumer loans
// 1995 added a 7th education loan category
gen educloanpmt = X7815*X7816 + X7838*X7839 + X7861*X7862 + X7915*X7916 + X7938*X7939 + X7961*X7962
replace educloanpmt = 0 if year == 1989
replace educloanpmt = educloanpmt + X7180*X7181  if year >= 1995

//before 1992 they asked about monthly payments
gen consloanpmt = X2718*X7527 + X2735*X7526 + X2818*X7525 + X2835*X7524 + X2918*X7523 + X2935*X7522 ///
+ X7184*X7185 if year >= 1995
replace consloanpmt = X2718 + X2735 + X2818 + X2835 + X2918 + X2935 if year <= 1992

gen pensloanpmt = X4011*X4012 
replace pensloanpmt = pensloanpmt + X11028*X11029 + X11128*X11129 + X11328*X11329 + X11428*X11429 if year >=2004
replace pensloanpmt = pensloanpmt + X11528*X11529 if year == 2004 | year == 2007

gen supportpmt = X5732/12 + X5734/12

gen committed_cons = rentpmt + homeloanpmt + carpmt + educloanpmt + consloanpmt + pensloanpmt + supportpmt

rename X4112 labearn1
rename X4712 labearn2 
rename X4131 selfearn1
rename X4731 selfearn2
replace labearn1 = 0 if labearn1<=0
replace labearn2 = 0 if labearn2<=0
replace selfearn1 = 0 if selfearn1<=0
replace selfearn2 = 0 if selfearn2<=0

// new variables
gen anticipates_expenses = 1 if (X3010 == 1)
replace anticipates_expenses = 0 if (X3010 == 5)
label values anticipates_expenses yesnolabel

gen saving_for_expense = 1 if inlist(X7186, 1, 6)
replace saving_for_expense = 0 if inlist(X7186, 5, 0)
label values saving_for_expense yesnolabel

rename X3008 budgeting_horizon
label define bhorizonlbl 1 "Next Few Months" 2 "Next Year" 3 "Next Few Years" 4 "Next 5-10 Years" 5 "Longer Than 20 Years"
label values budgeting_horizon bhorizonlbl

rename X3014 finrisktol
label define finrisktollbl 1 "Substantial risk" 2 "Above average" 3 "Average" 4 "None"

gen is_saving = 1 if (X3017 == 1) | (X3018 == 1) | (X3019 == 1) | (X3020 == 1)
replace is_saving = 0 if (X3015 == 1) | (X3016 == 1)
label values is_saving yesnolabel

gen finlit1 = 1 if (X7558 == 5)
replace finlit1 = 0 if (X7558 == 1)

gen finlit2 = 1 if (X7559 == 1)
replace finlit2 = 0 if inlist(X7559, 3, 5)

gen finlit3 = 1 if (X7560 == 5)
replace finlit3 = 0 if inlist(X7560, 1, 3)

gen isfinlit = 1 if (finlit1 == 1) & (finlit2 == 1) & (finlit3 == 1)
replace isfinlit = 0 if !missing(finlit1, finlit2, finlit3) & missing(isfinlit)
label values isfinlit yesnolabel

gen exercisedstockoption = (X6797 == 1) | (X6798 == 1)
label values exercisedstockoption yesnolabel

gen healthinsured = (X6357 == 1)
label values healthinsured yesnolabel

rename X7187 necessaryemergfunds

gen has_brokerage = (X3923 == 1)
// gen margin_loans = X3932

rename X816 loanrate1
rename X916 loanrate2
rename X1016 loanrate3
rename X1045 loanrate4
rename X1111 loanrate5
rename X1122 loanrate6
rename X1133 loanrate7
rename X1216 loanrate8
rename X2219 loanrate9
rename X2319 loanrate10
rename X2419 loanrate11
rename X7170 loanrate12
rename X2520 loanrate13
rename X2620 loanrate14
rename X7822 loanrate15
rename X7845 loanrate16
rename X7868 loanrate17
rename X7922 loanrate18
rename X7945 loanrate19
rename X7968 loanrate20
rename X2724 loanrate21
rename X2741 loanrate22
rename X2824 loanrate23
rename X2841 loanrate24
rename X2924 loanrate25
rename X2941 loanrate26
rename X4013 loanrate27
rename X1726 loanrate28
rename X1826 loanrate29

forvalues iloan = 1/29 {
	replace loanrate`iloan' = 0 if loanrate`iloan' < 0
	replace loanrate`iloan' = loanrate`iloan' / 10000
}

egen maxirate = rowmax(loanrate*)

gen retirself_value = X6551 + X6552 + X6553 + X6554
gen retirsp_value = X6559 + X6560 + X6561 + X6562
gen retirfam_value = X6567 + X6568 + X6569 + X6570
gen retir_value = retirself_value + retirsp_value + retirfam_value

gen retirself_pct_stocks = X6556 / 10000
gen retirsp_pct_stocks = X6564 / 10000
gen retirfam_pct_stocks = X6572 / 10000
gen annuity_pct_stocks = X6582 / 10000
gen trust_pct_stocks = X6592 / 10000

gen retirself_stocks = retirself_value * retirself_pct_stocks
gen retirsp_stocks = retirsp_value * retirsp_pct_stocks
gen retirfam_stocks = retirfam_value * retirfam_pct_stocks
gen retir_stocks = retirself_stocks + retirsp_stocks + retirfam_stocks

///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// runs the NBER's TAXSIM. See http://users.nber.org/~taxsim/taxsim-calc9/index.html
/*
// Install using the following commands
net from "http://www.nber.org/stata"
net describe taxsim9
net install taxsim9


if having problems, its probably your firewall as the website says. Select 
taxsim = 0 below to skip taxsim section.
*/

scalar taxsim = 0

// sets up required variables for TAXSIM
// Assumes that everyone files as single with no dependents
if taxsim==1 {
	gen state = 0
	gen mstat = 1
	gen depx = 0
	gen pwages = hh_earnings
	gen depchild = 0
	gen ui = uiben
	gen gssi = ssinc
	gen transfers = tanf + childben
	taxsim9, replace
	gen taxes_sing_nokids = fiitax + fica/2

	// Re-runs TAXSIM assuming every household files their marriage and dependent status
	replace X8023 = 1 if X8023 == 7 | X8023 == 8
	replace mstat = 1
	replace mstat = 2 if X8023 == 1 | X8023 == 2
	replace depx = (X108 == 4 | X108 == 13 | X108 == 36) + (X114 == 4 | X114 == 13 | X114 == 36) ///
	+ (X120 == 4 | X120 == 13 | X120 == 36) + (X126 == 4 | X126 == 13 | X126 == 36) ///
	+ (X132 == 4 | X132 == 13 | X132 == 36) + (X202 == 4 | X202 == 13 | X202 == 36) ///
	+ (X208 == 4 | X208 == 13 | X208 == 36) + (X214 == 4 | X214 == 13 | X214 == 36) ///
	+ (X220 == 4 | X220 == 13 | X220 == 36) + (X226 == 4 | X226 == 13 | X226 == 36) 
	replace depchild = depx
	taxsim9, replace
	gen taxes_mar_kids = fiitax + fica/2
}
else {
	gen taxes_mar_kids = 0
	gen taxes_sing_nokids = 0
}
///////////////////////////////////////////////////////////////////////////////
// deflates data provided for the year prior to the SCF surveys
// set to 0 to replicate paper
scalar cpilag = 0
if cpilag == 1 {
gen CPILAG = 0
replace CPILAG = 3526/3482 if year == 2016
replace CPILAG = 3422/3373 if year == 2013
replace CPILAG = 3203/3152 if year == 2010
replace CPILAG = 3046/2962 if year == 2007
replace CPILAG = 2775/2702 if year == 2004
replace CPILAG = 2601/2529 if year == 2001
replace CPILAG = 2395/2363 if year == 1998
replace CPILAG = 2253/2200 if year == 1995
replace CPILAG = 2102/2051 if year == 1992
replace CPILAG = 1886/1807 if year == 1989

local lagvars hh_earnings hh_selfy uiben childben tanf ssinc othinc labinc labincplus supportpmt usuallabinc
foreach lagvar of local lagvars {
replace `lagvar'=`lagvar'*CPILAG
}
}
///////////////////////////////////////////////////////////////////////////////
// deflates relevant data into 2010 terms using the CPI-U-RS http://www.bls.gov/cpi/cpiursai1978_2010.pdf
//use September values for each year (around when the survey was done)
gen CPIADJ = 0
scalar CPIBASE = 320.8
replace CPIADJ = CPIBASE/378.1 if year == 2019
replace CPIADJ = CPIBASE/363.5 if year == 2016
replace CPIADJ = CPIBASE/344.3 if year == 2013
replace CPIADJ = CPIBASE/320.8 if year == 2010
replace CPIADJ = CPIBASE/306.2 if year == 2007
replace CPIADJ = CPIBASE/278.8 if year == 2004
replace CPIADJ = CPIBASE/261.8 if year == 2001
replace CPIADJ = CPIBASE/240.5 if year == 1998
replace CPIADJ = CPIBASE/226.5 if year == 1995
replace CPIADJ = CPIBASE/211.6 if year == 1992
replace CPIADJ = CPIBASE/190.2 if year == 1989

local z ccdebt hh_earnings hh_selfy uiben childben tanf ssinc othinc labinc ///
	labincplus maxcredit rentpmt homeloanpmt carpmt educloanpmt consloanpmt ///
	pensloanpmt supportpmt committed_cons misc_illiq usuallabinc taxes_mar_kids ///
	taxes_sing_nokids heloc_lim labearn1 labearn2 selfearn1 selfearn2 ///
	committed_cons
foreach k of local z {
replace `k' = `k'*CPIADJ
}
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
//merges data with the extract data
merge 1:1 Y1 year using SCF_89_19_extract.dta
drop _merge
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// cleans up some of the extract data files
replace married = 0 if married == 2

rename edcl educcat
label define edlab 1 "<HS" 2 "HS" 3 "some college" 4 "college"
label values educcat edlab

gen educyears = 4 if (educ == 1)
replace educyears = 5 if (educ == 2)
replace educyears = 7 if (educ == 3)
replace educyears = 9 if (educ == 4)
replace educyears = 10 if (educ == 5)
replace educyears = 11 if (educ == 6)
replace educyears = 12 if (educ == 7)
replace educyears = 12 if (educ == 8)
replace educyears = 14 if inrange(educ, 9, 11)
replace educyears = 16 if (educ == 12)
replace educyears = 18 if (educ == 13) | (educ == 14)
replace educyears = 20 if (educ == 15)
replace educyears = 0 if (educ < 0)

gen educhigh = 0
replace educhigh = 1 if (educ == 12)
replace educhigh = 2 if inrange(educ, 13, 15)
label define educhighlbl 0 "Less" 1 "Bachelor's Degree" 2 "Graduate or Professional Degree"
label values educhigh educhighlbl

rename lf working

label define famlab 1 "not married with kids" 2 "not married, no kids, under 55" 3 "not married, no kids, over 55" 4 "married with kids" 5 "married, no kids"
label values famstruct famlab

// generates a variable for the imputation number
tostring Y1, generate(str_Y1)
gen im0100 = substr(str_Y1,-1,.)
destring im0100, replace

///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
cd ${basedir}/build/temp
save SCF_89_19_merged.dta, replace

// !rm SCF_89_19_full.dta
// !rm SCF_89_19_extract.dta
///////////////////////////////////////////////////////////////////////////////
