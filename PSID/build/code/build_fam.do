
use build/input/fam2013er/fam2013er, clear

gen year = 2013
rename ER53002 intid
rename ER53009 famid
rename ER54634 stocks
rename ER58257 lwgt
rename ER53017 ageh

drop ER*
compress

tempfile fam2013tmp
save `fam2013tmp'



use build/input/fam2015er/fam2015er, clear

gen year = 2015
rename ER60002 intid
rename ER60009 famid
rename ER61745 stocks
rename ER65492 lwgt
rename ER60019 ageh

drop ER*
compress

tempfile fam2015tmp
save `fam2015tmp'




clear
forvalues yr = 2013(2)2015 {
	append using `fam`yr'tmp'
}
