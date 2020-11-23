clear
*** Reads and cleans the PSID ***

*** Run do-file from PSID ***
do build/input/cross_year/cross_year.do

*** Rename variables ***
rename ER13002 intid1999
rename ER17002 intid2001
rename ER21002 intid2003
rename ER25002 intid2005
rename ER36002 intid2007
rename ER42002 intid2009
rename ER47302 intid2011
rename ER53002 intid2013
rename ER60002 intid2015
rename ER66002 intid2017

// partition sample by creating variable
// invtype = always, sometimes, rarely, never

// NOTE 1994 and earlier included IRAs

// add planned retirement age

// infer monthly stockholding patters from dividends
// infer past stockholders from dividends?

/*
rename V21833 divh_m1y1992
rename ER3220 divh_m1y1993
rename ER6220 divh_m1y1994
rename ER8337 divh_m1y1995
rename ER11230 divh_m1y1996
rename ER14496 divh_m1y1999
rename ER18653 divh_m1y2000
rename ER22024 divh_m1y2002
rename ER26005 divh_m1y2004
rename ER37023 divh_m1y2006
rename ER43014 divh_m1y2008
rename ER48336 divh_m1y2010
rename ER54013 divh_m1y2012
rename ER61055 divh_m1y2014
rename ER67107 divh_m1y2016

rename V21834 divh_m2y1992
rename ER3221 divh_m2y1993
rename ER6221 divh_m2y1994
rename ER8338 divh_m2y1995
rename ER11231 divh_m2y1996
rename ER14497 divh_m2y1998
rename ER18654 divh_m2y2000
rename ER22025 divh_m2y2002
rename ER26006 divh_m2y2004
rename ER37024 divh_m2y2006
rename ER43015 divh_m2y2008
rename ER48337 divh_m2y2010
rename ER54014 divh_m2y2012
rename ER61056 divh_m2y2014
rename ER67108 divh_m2y2016

rename V21835 divh_m3y1992
rename ER3222 divh_m3y1993
rename ER6222 divh_m3y1994
rename ER8339 divh_m3y1995
rename ER11232 divh_m3y1996
rename ER14498 divh_m3y1998
rename ER18655 divh_m3y2000
rename ER22026 divh_m3y2002
rename ER26007 divh_m3y2004
rename ER37025 divh_m3y2006
rename ER43016 divh_m3y2008
rename ER48338 divh_m3y2010
rename ER54015 divh_m3y2012
rename ER61057 divh_m3y2014
rename ER67109 divh_m3y2016
*/

rename ER13008A famchange1999
rename ER17007 famchange2001
rename ER21007 famchange2003
rename ER25007 famchange2005
rename ER36007 famchange2007
rename ER42007 famchange2009
rename ER47307 famchange2011
rename ER53007 famchange2013
rename ER60007 famchange2015
rename ER66007 famchange2017

rename V17363 netputinstocks1989
rename ER3800 netputinstocks1994
rename ER15078 netputinstocks1999
rename ER19274 netputinstocks2001
rename ER22669 netputinstocks2003
rename ER26650 netputinstocks2005
rename ER37668 netputinstocks2007
rename ER43659 netputinstocks2009
rename ER49004 netputinstocks2011

rename ER13114 boughtvehicle1y1999
rename ER17125 boughtvehicle1y2001
rename ER21764 boughtvehicle1y2003
rename ER25722 boughtvehicle1y2005
rename ER36740 boughtvehicle1y2007
rename ER42743 boughtvehicle1y2009
rename ER48061 boughtvehicle1y2011
rename ER53757 boughtvehicle1y2013
rename ER60816 boughtvehicle1y2015
rename ER66864 boughtvehicle1y2017

rename ER13144 boughtvehicle2y1999
rename ER17155 boughtvehicle2y2001
rename ER21793 boughtvehicle2y2003
rename ER25750 boughtvehicle2y2005
rename ER36768 boughtvehicle2y2007
rename ER42766 boughtvehicle2y2009
rename ER48086 boughtvehicle2y2011
rename ER53781 boughtvehicle2y2013
rename ER60840 boughtvehicle2y2015
rename ER66888 boughtvehicle2y2017

rename ER13174 boughtvehicle3y1999
rename ER17185 boughtvehicle3y2001
rename ER21822 boughtvehicle3y2003
rename ER25778 boughtvehicle3y2005
rename ER36796 boughtvehicle3y2007
rename ER42789 boughtvehicle3y2009
rename ER48111 boughtvehicle3y2011
rename ER53805 boughtvehicle3y2013
rename ER60864 boughtvehicle3y2015
rename ER66912 boughtvehicle3y2017

rename ER28037E2 cvacations2005
rename ER41027E2 cvacations2007
rename ER46971E2 cvacations2009
rename ER52395E2 cvacations2011
rename ER58212E2 cvacations2013
rename ER65447 cvacations2015
rename ER71526 cvacations2017

rename ER3217 wdivh1994
rename ER6217 wdivh1995
rename ER8334 wdivh1996
rename ER11227 wdivh1997
rename ER14493 wdivh1999
rename ER18649 wdivh2001
rename ER22019 wdivh2003
rename ER26000 wdivh2005
rename ER37018 wdivh2007
rename ER43009 wdivh2009
rename ER48331 wdivh2011
rename ER54008 wdivh2013
rename ER61050 wdivh2015
rename ER67102 wdivh2017

rename ER3523 wdivsp1994
rename ER6524 wdivsp1995
rename ER8641 wdivsp1996
rename ER11523 wdivsp1997
rename ER14789 wdivsp1999
rename ER18965 wdivsp2001
rename ER22352 wdivsp2003
rename ER26333 wdivsp2005
rename ER37351 wdivsp2007
rename ER43342 wdivsp2009
rename ER48667 wdivsp2011
rename ER54361 wdivsp2013
rename ER61437 wdivsp2015
rename ER67457 wdivsp2017

rename V10940 gift1y1984
rename V17384 gift1y1989
rename ER3838 gift1y1994
rename ER15117 gift1y1999
rename ER19313 gift1y2001
rename ER22708 gift1y2003
rename ER26689 gift1y2005
rename ER37707 gift1y2007
rename ER43698 gift1y2009
rename ER49043 gift1y2011
rename ER54799 gift1y2013
rename ER61913 gift1y2015
rename ER67967 gift1y2017

rename ER3843 gift2y1994
rename ER15122 gift2y1999
rename ER19318 gift2y2001
rename ER22713 gift2y2003
rename ER26694 gift2y2005
rename ER37712 gift2y2007
rename ER43703 gift2y2009
rename ER49048 gift2y2011
rename ER54804 gift2y2013
rename ER61921 gift2y2015
rename ER67975 gift2y2017

rename ER3848 gift3y1994
rename ER15127 gift3y1999
rename ER19323 gift3y2001
rename ER22718 gift3y2003
rename ER26699 gift3y2005
rename ER37717 gift3y2007
rename ER43708 gift3y2009
rename ER49053 gift3y2011
rename ER54809 gift3y2013
rename ER61929 gift3y2015
rename ER67983 gift3y2017

rename ER16515A1 cfood1999
rename ER16515A5 chousing1999
rename ER16515B6 ctransport1999
rename ER16515C9 ceduc1999
rename ER16515D1 cchild1999
rename ER16515D2 chealth1999

rename ER20456A1 cfood2001
rename ER20456A5 chousing2001
rename ER20456B6 ctransport2001
rename ER20456C9 ceduc2001
rename ER20456D1 cchild2001
rename ER20456D2 chealth2001

rename ER24138A1 cfood2003
rename ER24138A5 chousing2003
rename ER24138B6 ctransport2003
rename ER24138C9 ceduc2003
rename ER24138D1 cchild2003
rename ER24138D2 chealth2003

rename ER28037A1 cfood2005
rename ER28037A5 chousing2005
rename ER28037B7 ctransport2005
rename ER28037D1 ceduc2005
rename ER28037D2 cchild2005
rename ER28037D3 chealth2005

rename ER41027A1 cfood2007
rename ER41027A5 chousing2007
rename ER41027B7 ctransport2007
rename ER41027D1 ceduc2007
rename ER41027D2 cchild2007
rename ER41027D3 chealth2007

rename ER46971A1 cfood2009
rename ER52395A1 cfood2011
rename ER58212A1 cfood2013
rename ER65410 cfood2015
rename ER71487 cfood2017

rename ER46971A5 chousing2009
rename ER52395A5 chousing2011
rename ER58212A5 chousing2013
rename ER65414 chousing2015
rename ER71491 chousing2017

rename ER46971B7 ctransport2009
rename ER52395B7 ctransport2011
rename ER58212B7 ctransport2013
rename ER65425 ctransport2015
rename ER71503 ctransport2017

rename ER46971D1 ceduc2009
rename ER52395D1 ceduc2011
rename ER58212D1 ceduc2013
rename ER65437 ceduc2015
rename ER71515 ceduc2017

rename ER46971D2 cchild2009
rename ER52395D2 cchild2011
rename ER58212D2 cchild2013
rename ER65438 cchild2015
rename ER71516 cchild2017

rename ER46971D3 chealth2009
rename ER52395D3 chealth2011
rename ER58212D3 chealth2013
rename ER65439 chealth2015
rename ER71517 chealth2017

rename S410 wstocks1999
rename S510 wstocks2001
rename S610 wstocks2003
rename S710 wstocks2005
rename S810 wstocks2007
rename ER46952 wstocks2009
rename ER52356 wstocks2011
rename ER58169 wstocks2013
rename ER65366 wstocks2015
rename ER71443 wstocks2017

rename S411 stocks1999
rename S511 stocks2001
rename S611 stocks2003
rename S711 stocks2005
rename S811 stocks2007
rename ER46954 stocks2009
rename ER52358 stocks2011
rename ER58171 stocks2013
rename ER65368 stocks2015
rename ER71445 stocks2017

rename ER15007 ostocks1999
rename ER19203 ostocks2001
rename ER22568 ostocks2003
rename ER26549 ostocks2005
rename ER37567 ostocks2007
rename ER43558 ostocks2009
rename ER48883 ostocks2011
rename ER54634 ostocks2013
rename ER61745 ostocks2015
rename ER67798 ostocks2017

rename ER15006 wostock1999
rename ER19202 wostock2001
rename ER22567 wostock2003
rename ER26548 wostock2005
rename ER37566 wostock2007
rename ER43557 wostock2009
rename ER48882 wostock2011
rename ER54633 wostock2013
rename ER61744 wostock2015
rename ER67797 wostock2017

rename V17365 stockbought1989
rename ER3805 stockbought1994
rename ER15083 stockbought1999
rename ER19279 stockbought2001
rename ER22674 stockbought2003
rename ER26655 stockbought2005
rename ER37673 stockbought2007
rename ER43664 stockbought2009
rename ER49009 stockbought2011
rename ER54764 stockbought2013
rename ER61875 stockbought2015
rename ER67929 stockbought2017

rename V17368 soldstock1989
rename ER3811 soldstock1994
rename ER15089 soldstock1999
rename ER19285 soldstock2001
rename ER22680 soldstock2003
rename ER26661 soldstock2005
rename ER37679 soldstock2007
rename ER43670 soldstock2009
rename ER49015 soldstock2011
rename ER54770 soldstock2013
rename ER61881 soldstock2015
rename ER67935 soldstock2017

rename S417 wealth1999
rename S517 wealth2001
rename S617 wealth2003
rename S717 wealth2005
rename S817 wealth2007
rename ER46970 wealth2009
rename ER52394 wealth2011
rename ER58211 wealth2013
rename ER65408 wealth2015
rename ER71485 wealth2017

rename ER15020 cash1999
rename ER19216 cash2001
rename ER22596 cash2003
rename ER26577 cash2005
rename ER37595 cash2007
rename ER43586 cash2009
rename ER48911 cash2011
rename ER54661 cash2013
rename ER61772 cash2015
rename ER67826 cash2017

rename ER13041 house1999
rename ER17044 house2001
rename ER21043 house2003
rename ER25029 house2005
rename ER36029 house2007
rename ER42030 house2009
rename ER47330 house2011
rename ER53030 house2013

rename V10903 vehicles1984
rename V17320 vehicles1989
rename ER3726 vehicles1994
rename ER14997 vehicles1999
rename ER19193 vehicles2001
rename ER22558 vehicles2003
rename ER26539 vehicles2005
rename ER37557 vehicles2007
rename ER43548 vehicles2009
rename ER48873 vehicles2011
rename ER54620 vehicles2013
rename ER61731 vehicles2015
rename ER67784 vehicles2017

rename ER13047 mortrem1999
rename ER17052 mortrem2001
rename ER21051 mortrem2003
rename ER25042 mortrem2005
rename ER36042 mortrem2007
rename ER42043 mortrem2009
rename ER47348 mortrem2011
rename ER53048 mortrem2013

rename ER13049 mortratewhole1999
rename ER17056 mortratewhole2001
rename ER21055 mortratewhole2003
rename ER25046 mortratewhole2005
rename ER36046 mortratewhole2007
rename ER42047 mortratewhole2009
rename ER47355 mortratewhole2011
rename ER53055 mortratewhole2013

rename ER13050 mortratedecimal1999
rename ER17057 mortratedecimal2001
rename ER21056 mortratedecimal2003
rename ER25047 mortratedecimal2005
rename ER36047 mortratedecimal2007
rename ER42048 mortratedecimal2009
rename ER47356 mortratedecimal2011
rename ER53056 mortratedecimal2013

rename ER13051 yearobtmort1999
rename ER17058 yearobtmort2001
rename ER21057 yearobtmort2003
rename ER25048 yearobtmort2005
rename ER36049 yearobtmort2007
rename ER42050 yearobtmort2009
rename ER47357 yearobtmort2011
rename ER53057 yearobtmort2013

rename S420 homequity1999
rename S520 homequity2001
rename S620 homequity2003
rename S720 homequity2005
rename S820 homequity2007
rename ER46966 homequity2009
rename ER52390 homequity2011
rename ER58207 homequity2013

rename ER16463 earnings1999
rename ER20443 earnings2001
rename ER24116 earnings2003
rename ER27931 earnings2005
rename ER40921 earnings2007
rename ER46829 earnings2009
rename ER52237 earnings2011
rename ER58038 earnings2013
rename ER65216 earnings2015
rename ER71293 earnings2017

rename ER13010 ageh1999
rename ER17013 ageh2001
rename ER21017 ageh2003
rename ER25017 ageh2005
rename ER36017 ageh2007
rename ER42017 ageh2009
rename ER47317 ageh2011
rename ER53017 ageh2013
rename ER60017 ageh2015
rename ER66017 ageh2017

rename ER16518 lwgt1999
rename ER20394 lwgt2001
rename ER24179 lwgt2003
rename ER28078 lwgt2005
rename ER41069 lwgt2007
rename ER47012 lwgt2009
rename ER52436 lwgt2011
rename ER58257 lwgt2013
rename ER65492 lwgt2015
rename ER71570 lwgt2017

rename ER13006 month1999
rename ER17009 month2001
rename ER21012 month2003
rename ER25012 month2005
rename ER36012 month2007
rename ER42012 month2009
rename ER47312 month2011
rename ER53012 month2013
rename ER60012 month2015
rename ER66012 month2017

rename ER16516 educ1999
rename ER20457 educ2001
rename ER24148 educ2003
rename ER28047 educ2005
rename ER41037 educ2007
rename ER46981 educ2009
rename ER52405 educ2011
rename ER58223 educ2013
rename ER65459 educ2015
rename ER71538 educ2017

drop ER* S* V*

*** Reshape long ***
gen famid = _n
#delimit ;
reshape long intid stocks wealth cash house mortrem mortratewhole
	mortratedecimal yearobtmort homequity earnings ageh lwgt
	cfood chousing ctransport ceduc cchild chealth wstocks
	educ month gift1y gift2y gift3y soldstock stockbought vehicles
	wdivh wdivsp boughtvehicle1y boughtvehicle2y famchange
	boughtvehicle3y cvacations netputinstocks ostocks wostock,
	i(famid) j(year);
#delimit cr

sort famid year
order famid year
drop if missing(intid)

*** Code missings ***
replace cash = . if (cash == 999999998) | (cash == 999999999)
replace age = . if (age == 999)
replace mortratewhole = . if (mortratewhole == 98) | (mortratewhole == 99)
replace mortratedecimal = . if (mortratedecimal == 998) | (mortratedecimal == 999)
replace house = . if (house == 9999998) | (house == 9999999)
replace mortrem = . if (mortrem == 9999998) | (mortrem == 9999999)
replace yearobtmort = . if (yearobtmort == 9998) | (yearobtmort == 9999)
replace educ = . if (educ == 99)
replace gift1y = . if inrange(gift1y, 9999997, 9999999)
replace gift2y = . if inrange(gift1y, 9999997, 9999999)
replace gift3y = . if inrange(gift1y, 9999997, 9999999)
recode wostock (8 9 = .) (5 = 0)
replace ostock = . if inrange(ostock, 999999998, 999999999)

label variable wdivh "Head received dividends in the previous year"
label variable wdivsp "Spouse received divdends in the previous year"

*** Quintiles ***
gen period = .
local ip = 1
gen quint_wealth = .
gen quint_earn = .
label define quintlbl 1 "Bottom" 5 "Top"
forvalues yr = 1999(2)2017 {
	replace period = `ip' if year ==  `yr'

	xtile qtempw = wealth [aw=lwgt] if year == `yr', nquantiles(5)
	replace quint_wealth = qtempw if year == `yr'
	
	xtile qtempe = earnings [aw=lwgt] if year == `yr', nquantiles(5)
	replace quint_earn = qtempe if year == `yr'

	drop qtempw qtempe
	local ip = `ip' + 1
}
label values quint_wealth quintlbl
label values quint_earn quintlbl

*** New variables ***
gen consumption = cfood + chousing + ctransport + ceduc + cchild + chealth

egen gifts = rowtotal(gift1y gift2y gift3y), missing
drop gift1y gift2y gift3y

bysort famid: gen gtemp = sum(gifts)
gen recdgifts = (gifts > 0) & !missing(gifts)
drop gtemp

gen nofamchange = (famchange == 0)
gen nomajorfamchange = inlist(famchange, 0, 1)

gen newcar = (boughtvehicle1y == 1) | (boughtvehicle2y == 1) | (boughtvehicle3y == 1)

gen recddividends = .
replace recddividends = 1 if (wdivh == 1) | (wdivsp == 1)
replace recddividends = 0 if (wdivh == 5) & (wdivsp == 5)
label variable recddividends "Received dividend income in the previous year"

gen imort = mortratewhole / 100 + mortratedecimal / 100000
drop mortrate*

gen has_stocks = stocks > 0
bysort famid: egen ever_had_stocks = max(has_stocks) if !missing(stocks)
bysort famid: egen nyears = count(stocks)
bysort famid: egen yrs_stockholder = total(has_stocks)
gen time_in = yrs_stockholder / nyears if (nyears > 0)

gen liquid = stocks + cash
gen stshare = stocks / liquid if (liquid > 0) & !missing(liquid)
gen cond_stshare_liquid = stshare if (stocks > 0) & !missing(stocks)
gen cond_stshare_wealth = stocks / wealth if (wealth > 0) & (stocks > 0)

tsset famid period
gen switch = (stocks > 0) & (L.stocks == 0)
replace switch = 1 if (stocks == 0) & (L.stocks > 0)
replace switch = . if missing(L.stocks)

gen entered_stocks = (stocks > 0) & (L.stocks == 0) if !missing(stocks, L.stocks)
gen left_stocks = (stocks == 0) & (L.stocks > 0) if !missing(stocks, L.stocks)
gen always_holding = (yrs_stockholder >= nyears - 1) if (nyears >= 6)
gen recently_holding = (has_stocks == 1) & (L.has_stocks == 1) & (always_holding == 0) if !missing(always_holding)
gen new_entrants = (entered_stocks == 1) & (always_holding == 0) if !missing(always_holding, entered_stocks)

gen investortype = .
replace investortype = 0 if (time_in == 0) & (nyears >= 6)
replace investortype = 1 if (time_in > 0) & (time_in < 1/2) & (nyears >= 6)
replace investortype = 2 if (time_in >= 1/2) & !missing(time_in) & (nyears >= 6)
label define invtypelbl 0 "Nonstockholder" 1 "Stock dabbler" 2 "Buy-and-hold"
label values investortype invtypelbl

gen homeowner = (house > 0) if !missing(house)
gen newhome = (L.house == 0) & (house > 0)
gen largepurchase = (newcar == 1) | (newhome == 1) | ((cvacations > 3000) & !missing(cvacations))


*** Cleaning and sample selection ***
drop if !inrange(age, 25, 55)
drop if stocks < 0

*** Deflate nominal variables with PCE ***
merge m:1 year month using "../SurveyOfConsumers/build/output/pce.dta", nogen keep(1 3)
gen ptemp = pce if (year == 2015) & (month == 10)
egen price2015 = max(ptemp)
drop ptemp

gen pricelev = pce / price2015
drop pce price2015

local nomvars consumption wealth stocks earnings gifts
foreach nvar of local nomvars {
	replace `nvar' = `nvar' / pricelev
}

** Merge with stock returns ***
merge m:1 year month using "../SurveyOfConsumers/build/output/stocks.dta", nogen keep(1 3)

save build/output/output.dta, replace
