

// Load tariffs 


import excel  "$xls_pry", sheet("vat_rates_2019") first clear      // Cargar tarifas y formalidad en la cadena

keep ga01c iva19 isc19

tempfile tariffs
save `tariffs'

// Load expenditures database 

use "$data_pry\data_prep_indtaxes.dta", clear

keep if gasto_compra!=0


// Collapse at the hh-item  level

collapse (sum) gasto_compra (max) formal2, by(UPM NVIVI NHOGA ga01c)

merge m:1 ga01c using `tariffs'

drop if _merge==2

drop _merge

// merge iva indirect effects 

format ga01c %12.0g


merge m:1 ga01c using `indirect_effects_IVA'

drop if _merge==2

drop _merge


// Formal purchases 


// Calculate IVA

gen dir_iva=0

gen dir_isc=0

gen indir_iva=0


// Direct effects



replace iva19=iva19/100
replace isc19=isc19/100


replace dir_iva= gasto_compra*iva19/(1+iva19)

replace dir_isc= gasto_compra*isc19/(1+isc19)


// indirect effects

replace indir_iva= gasto_compra*indirect_effect_iva



// Formality 

replace dir_iva=0     if    formal2==0

replace dir_isc=0     if    formal2==0


replace indir_iva=0   if    formal2==0 

// Total IVA

egen total_iva=rowtotal(dir_iva indir_iva)

gen total_isc=dir_isc


// Nafta expenses 

gen nafta_expenses= gasto_compra    if      ga01c==502201007    | ga01c==502201001 | ga01c==502201002  | ga01c==502201003
 
gen diesel_expenses= gasto_compra         if      ga01c==502201004

// Collapse at the hh level


collapse (sum) total_iva  nafta_expenses diesel_expenses total_isc gasto_compra, by(UPM NVIVI NHOGA)

gen ratio= total_iva/ gasto_compra

gen ratio_nafta= nafta_expenses/ gasto_compra

gen ratio_diesel= diesel_expenses/ gasto_compra

tempfile cons_tax

save `cons_tax'










