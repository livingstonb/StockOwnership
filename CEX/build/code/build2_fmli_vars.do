
clear*
set more 1
cap mkdir ${basedir}/build/output

////////////////////////////////////////////////////////////////////////////////
* CLEAN

use ${basedir}/build/temp/fmli_allyears, clear

* CU characteristics
gen id = newid
gen age = age_ref
gen agesp = age2
gen housetenure	= cutenure
gen educ = educ_ref
gen educsp = educa2
gen famsize = fam_size
gen intmonth = qintrvmo
gen intyear = qintrvyr
gen race1 = ref_race
gen sex = sex_ref

* Create datetime variable;
gen qdate = string(year) + " Q" + string(q)
gen YQ = quarterly(qdate,"YQ")
format YQ %tq
tsset id YQ
order id YQ

* Wealth variables;
gen ccdebt = .
replace	ccdebt = 0 if creditb=="1"
replace	ccdebt = 500 if creditb=="2"
replace ccdebt = 1000 if creditb=="3"
replace ccdebt = 2500 if creditb=="4"
replace ccdebt = 10000 if creditb=="5"
replace ccdebt = 35000 if creditb=="6"
replace ccdebt = creditx if !missing(creditx)

gen checking = ckbkactx	if YQ <= quarterly("2013q1", "YQ")
replace	checking = 500	if liquidb=="1"
replace checking = 1000	if liquidb=="2"
replace checking = 2500 if liquidb=="3"
replace checking = 10000 if liquidb=="4"
replace checking = 35000 if inlist(liquidb,"5","6")
replace checking = liquidx if !missing(liquidx)

gen saving = savacctx if YQ <= quarterly("2013Q1", "YQ")
* saving included in liquidx for 2013q2-
replace	saving = 0 if (YQ >= quarterly("2013Q2","YQ")) & !missing(checking)
gen stocks = secestx if YQ <= quarterly("2013Q1", "YQ")
replace	stocks = stockx if YQ > quarterly("2013Q1", "YQ")
gen studentdebt = studntx if YQ > quarterly("2013Q1", "YQ")
gen retacc = irax if YQ > quarterly("2013Q1", "YQ")
gen othassets = othastx if YQ > quarterly("2013Q1", "YQ")
gen othdebt = othlonx if YQ > quarterly("2013Q1", "YQ")
gen savbond = usbndx if YQ > quarterly("2013Q1", "YQ")

gen pension = fpripenx
replace	pension = fpripenm if missing(pension)

* Income variables
gen income_post	= finatxem if YQ > quarterly("2013Q1", "YQ")
gen income_pre = fincbtxm if YQ >= quarterly("2004Q1", "YQ")
gen wages = fsalaryx
replace	wages = fsalarym if YQ >= quarterly("2004Q1", "YQ")
gen farm = ffrmincx
replace	farm = ffrmincm if missing(farm)
gen bus = fnonfrmx
replace	bus = fnonfrmm if missing(bus)
gen selfearn = fsmpfrxm if YQ > quarterly("2013Q1", "YQ")
gen rentinc = inclossa
replace	rentinc	= inclosam if missing(rentinc)
replace	rentinc	= netrentm if YQ > quarterly("2013Q1", "YQ")
gen savint = intearnx
replace	savint	= intearnm if missing(savint)
gen int_and_div	= intrdvxm
gen lumpsumtrust = lumpsumx
gen dividtrust = finincxm
gen royalttrust	= royestxm
gen alimony = aliothxm
gen childsupp = chdlmpx
gen othchildsupp = chdothxm
gen workcomp = compensm
gen foodstamps = foodsmpx
replace	foodstamps = foodsmpm if missing(foodstamps)
gen socsec = frretirx
replace	socsec = frretirm if missing(socsec)
gen ssi = fssix
replace	ssi = fssixm if missing(ssi)
gen othinc = othregxm
gen othinc2 = othrincx
replace	othinc2 = othrincm if missing(othinc2)
gen pensioninc = pensionx
replace	pensioninc = pensionm if missing(pensioninc)
// gen		retsurvivor		= retsurvm;				/* 2013q2- */;
// gen		saleshousehold	= saleincx;				/* - 2013q1 */;
// gen		uiben			= unemplx;				/* -2004q1,2006q1-2013q1 */; 
// replace	uiben			= unemplxm if uiben==.;	/* 2004q1-2013q1 */;
// gen		localwelf		= welfarex;				/* -2004q1,2006q1- */;
// replace	localwelf		= welfarem if localwelf--.; /* 2004q1- */;

* Tax variables;
// gen		feddeducted		= famtfedx;				/* -2004q1,2006q1-2015q1 */;
// replace	feddeducted		= famtfedm 	if feddeducted==.;	/* 2004q1-2015q1 */;
// gen		fedrefund		= fedr_ndx				/* -2015q1 */;
// gen		proptax			= proptxcq*4;			/* - */;
// gen		othproptax		= taxpropx;				/* -2013q1 */;
// gen		salt			= sloctaxx;				/* -2015q1 */;	
// replace	salt			= fsltaxx 	if salt==.;	/* -2004q1,2006q1-2015q1 */;
// replace	salt			= fsltaxxm 	if salt==.;	/* 2004q1-2015q1 */;
// gen		saltrefund		= slrfundx;				/* -2015q1 */;
// gen		totalptax		= tottxpdx;				/* -2004q1,2006q1-2014q1 */;
// replace	totalptax		= tottxpdm if totalptax==.; /* 2004q1-2014q5 */;

* Consumption;
gen totalexp = totex4cq

* Other;
gen incrank = inc_rnkm
gen poverty = pov_cym
gen wgt	= finlwt21

////////////////////////////////////////////////////////////////////////////////
* KEEP ONLY NECESSARY VARIABLES (multiple imputations create very large dataset);
#delimit ;
keep id year age income_post wgt income_pre totalexp YQ saving stocks ccdebt
	checking wages finatxe* fincbtx* wtrep*;
#delimit cr

////////////////////////////////////////////////////////////////////////////////
* MULTIPLE IMPUTATIONS;
// expand 5;
// bysort id: gen obsid = _n;
// gen imps = 1 if obsid == 1;
// replace imps = 2 if obsid == 2;
// replace imps = 3 if obsid == 3;
// replace imps = 4 if obsid == 4;
// replace imps = 5 if obsid == 5;
// * add imputations only for necessary variables (saves a lot of time);
// local impvars finatxe fincbtx; /* fsalary ffrminc fnonfrm
// 	fsmpfrx inclosa netrent intearn intrdvx finincx royestx aliothx
// 	chdothx compens foodsmp frretir fssix othregx othrinc pension retsurv
// 	unemplx welfare famtfed fsltaxx tottxpd inc_rnk */;
// foreach impvar of local impvars {;
// 	di "`impvar'";
// 	gen imp_`impvar' = .;
// 	forvalues i=1/5 {;
// 		replace imp_`impvar' = `impvar'`i' if imps==`i';
// 	};
// };
//
// rename imp_finatxe imp_income_post;
// rename imp_fincbtx imp_income_pre;
// rename imps reps;
// gen im0100 = reps;
//
// forvalues i= 1/44{;
// 	if `i' < 10 {;
// 		rename wtrep0`i' wt1b`i';
// 	};
// 	else {;
// 		rename wtrep`i' wt1b`i';
// 	};
// };
//
// forvalues i=44(-1)1 {;
// 	gen mm`i' = 1;
// };

////////////////////////////////////////////////////////////////////////////////
* DEFINE NEW VARIABLES;

gen brliqpos = checking + saving + stocks
gen brliqneg = ccdebt
gen netbrliq = brliqpos - brliqneg

////////////////////////////////////////////////////////////////////////////////
* SAVE
sort id YQ
order id YQ
compress
save ${basedir}/build/output/CEXfmli, replace
