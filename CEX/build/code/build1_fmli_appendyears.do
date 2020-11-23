
clear*
set more 1
cap mkdir ${basedir}/build/temp
////////////////////////////////////////////////////////////////////////////////

* Create yearly datasets first
local years 15 16 // 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16
local ii = 2
foreach yy of local years {
	if "`yy'" == "00" {
		local nxyr 17
	}
	else {
		local nxyr "`:word `ii' of `years''"
		local ii = `ii' + 1
	}
	
	if `yy' < 80 {
		local yyyy = 20`yy'
	}
	else {
		local yyyy = 19`yy'
	}
	
	if `nxyr' < 80 {
		local nxyyyy = 20`nxyr'
	}
	else {
		local nxyyyy = 19`nxyr'
	}
	
	
	use build/input/intrvw`yy'/intrvw`yy'/fmli`yy'1x.dta, clear
	append using build/input/intrvw`yy'/intrvw`yy'/fmli`yy'2.dta
	append using build/input/intrvw`yy'/intrvw`yy'/fmli`yy'3.dta
	append using build/input/intrvw`yy'/intrvw`yy'/fmli`yy'4.dta
	append using build/input/intrvw`yy'/intrvw`yy'/fmli`nxyr'1.dta
	
	gen month = real(qintrvmo)
	gen quarter = 3 
	replace quarter = 1 if (qintrvmo == "01" | qintrvmo == "02" | ///
		qintrvmo == "03") & qintrvyr == "`yyyy'" 
	replace quarter = 5 if (qintrvmo == "01" | qintrvmo == "02" | ///
		qintrvmo == "03") & qintrvyr == "`nxyyyy'" 

	gen popwt = finlwt21*(((month-1)/3)/4) if quarter == 1 
	replace popwt = finlwt21*(((4-month)/3)/4) if quarter == 5 
	replace popwt = finlwt21/4 if quarter == 3
	
	egen aggpop = sum(popwt)
	cap destring newid, force replace
	gen ncuid = newid / 10
	replace ncuid = floor(ncuid)
	save build/temp/fmli`yyyy'.dta, replace
	clear
	
	if inlist("`yyyy'", "2015") {
	use build/input/intrvw`yy'/intrvw`yy'/mtbi`yy'1x.dta, clear
	append using build/input/intrvw`yy'/intrvw`yy'/mtbi`yy'2.dta
	append using build/input/intrvw`yy'/intrvw`yy'/mtbi`yy'3.dta
	append using build/input/intrvw`yy'/intrvw`yy'/mtbi`yy'4.dta
	append using build/input/intrvw`yy'/intrvw`yy'/mtbi`nxyr'1.dta
	
	cap destring ucc, replace
	cap destring ref_yr, replace
	keep if ref_yr == `yyyy'
	collapse (sum) cost, by(newid)
	
	save build/temp/mtbi`yyyy'.dta, replace
	clear
	
	use build/temp/fmli`yyyy'.dta, clear
	merge 1:m newid using "build/temp/mtbi`yyyy'.dta", nogen
	replace cost = 0 if missing(cost)
	save build/temp/merged`yyyy'.dta, replace
	}
}

* Append years;
foreach yyyy of numlist 1997/2016 {;
	if `yyyy'==1997 {;
		use ${basedir}/build/temp/fmli`yyyy', clear;
	};
	else {;
		append using ${basedir}/build/temp/fmli`yyyy';
	};
	rm ${basedir}/build/temp/fmli`yyyy'.dta;
};

* Save;
save ${basedir}/build/temp/fmli_allyears, replace;


