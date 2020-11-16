
clear
import delimited "build/input/census2000codes.csv", varnames(1) delimiters("\t")
encode occlabel, gen(censusocc)

save build/output/occ_codes.dta, replace
