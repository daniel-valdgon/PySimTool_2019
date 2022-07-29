

// Load tariffs 


import excel  "$xls_pry", sheet("vat_rates") first clear      // Cargar tarifas y formalidad en la cadena

keep ga01c iva19 isc19

tempfile tariffs
save `tariffs'

// Load expenditures database 

use "$data_pry\data_prep_indtaxes.dta", clear

rename sectorio sector 

keep if gasto_compra!=0


// Collapse at the hh-item  level

collapse (sum) gasto_compra (max) formal2 sector, by(UPM NVIVI NHOGA sectorioe ga01c)

merge m:1 ga01c using `tariffs'

drop if _merge==2

drop _merge

// merge iva indirect effects 

format ga01c %12.0g


merge m:1 ga01c using `indirect_effects_IVA'

drop if _merge==2

drop _merge


merge m:1 sector using `indirect_fuels'

drop if _merge==2

drop _merge




// Formal purchases 
encode sectorioe , gen(sec_num)
// Nafta expenses 

gen nafta_expenses= gasto_compra         if      ga01c==502201007    | ga01c==502201001 | ga01c==502201002  | ga01c==502201003

gen diesel_expenses= gasto_compra         if      ga01c==502201004

gen servotros_expenses= gasto_compra     if      sec_num==25

gen transporte_expenses= gasto_compra    if      sec_num==35

gen carne_expenses= gasto_compra         if      sec_num==5





// Calculate IVA

gen dir_iva=0

gen dir_isc=0

gen dir_fuels=0       // nafta 

gen dir_fuels_II=0     // diesel 


gen indir_iva=0

gen indir_fuels=0

replace iva19=iva19/100

replace isc19=isc19/100



// Direct effects

replace dir_iva= gasto_compra*iva19/(1+iva19)

replace dir_isc= gasto_compra*isc19/(1+isc19)

replace dir_fuels= nafta_expenses*shock_fuels[1,1]

replace dir_fuels_II= diesel_expenses*shock_fuels[1,2]


// indirect effects

replace indir_iva= gasto_compra*indirect_effect_iva

// indirect fuels

replace indir_fuels= gasto_compra*indirect_effect_fuels

// indirect fuels by sector 


forvalues ii=1/36  {
	
gen indir_fuels_`ii'=	indir_fuels  if  sec_num==`ii'

}	


// Formality 

replace dir_iva=0     if    formal2==0

replace dir_isc=0     if    formal2==0


replace indir_iva=0   if    formal2==0 

// Total IVA

egen total_iva=rowtotal(dir_iva indir_iva)

gen total_isc=dir_isc


// Total fuels 

egen total_fuels=rowtotal(dir_fuels indir_fuels)


// Collapse at the hh level

collapse (sum) total_iva diesel_expenses total_isc gasto_compra dir_fuels_II dir_iva indir_iva nafta_expenses servotros_expenses transporte_expenses carne_expenses total_fuels dir_fuels indir_fuels*, by(UPM NVIVI NHOGA)


gen ratio_iva = total_iva/gasto_compra

gen ratio_isc = total_isc/gasto_compra

gen ratio_fuels = total_fuels/gasto_compra

gen ratio_fuels_dir = dir_fuels/gasto_compra

gen ratio_fuels_indir = indir_fuels/gasto_compra

gen ratio_sotros = servotros_expenses/gasto_compra

gen ratio_stransporte = transporte_expenses/gasto_compra

gen ratio_carne = carne_expenses/gasto_compra

gen ratio_nafta = nafta_expenses/gasto_compra

gen ratio_diesel  = diesel_expenses/gasto_compra

gen ratio_dir_diesel  = dir_fuels_II/gasto_compra


tempfile cons_tax

merge 1:1 UPM NVIVI NHOGA using "$data_pry\eig_toimpute.dta" , keepusing(hhid hhsize )

keep if _merge==3

save `cons_tax'

**gen all=1

**collapse (sum) indir_fuels_*  [aw=fex]  , by (all)
















