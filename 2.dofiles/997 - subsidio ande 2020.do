

//Macros
local sub2020 $sub2020
local sub2021_1 $sub2021_1
local sub2021_2 $sub2021_2
local sub2021_3 $sub2021_3

* Para el 2020, el subsidio era de 100% exoneracion de pago de Consumo para hogares que consumen menos de 500 KWH

use "$data_pry\data_prep_individuo_elect.dta", clear


	if ($doande== 1) {

	xtile decilipcm = ipcm [w=fex], nq(10)
	
** Generating beneficiaries

capture drop bene_ande
gen        bene_ande = (gasto_electricidad < `sub2020')
tab         decilipcm bene_ande [w=fex] 

** Generating ammount of benefits
capture drop monto_sub_ande1
gen        monto_sub_ande1=gasto_electricidad*0.5 if bene_ande==1
//gen        monto_sub_ande1=gasto_electricidad*0 if bene_ande==1
replace monto_sub_ande1=gasto_electricidad-gasto_electricidad if bene_ande==0
table     decilipcm bene_ande [w=fex] , c( mean monto_sub_ande1 sum monto_sub_ande1 ) row col  

* Numero de hogares por decil 
capture drop decilipcmh
xtile       decilipcmh=ipcm if jefe==1 [w=fex], nq(10)

*shares 
capture drop sh_monto
gen sh_monto=monto_sub_ande1/gasto_electricidad
table     decilipcmh bene_ande [w=fex] , c( mean monto_sub_ande1 freq mean sh_monto mean gasto_electricidad)
tabstat sh_monto [w=fex ], by(decilipcmh)

preserve
cd "$path\3.Tool\"

*xtable decilipcmh if bene_ande==1 [w=fex] , c( sum monto_sub_ande1 freq mean sh_monto ) format(%9.3f) sc filename("PYsim.xls") sheet("ande_new", replace) modify
restore

  preserve 
	collapse (mean) sh_monto  [w=fex], by(decilipcmh)
	export excel "$xls_pry", sheet(indiv_ande) sheetreplace first(variable)
	restore


//gen gasto_electricidad_newFS = gasto_electricidad*0 if consumokwh<=500 & consumokwh!=.
gen gasto_electricidad_newFS = gasto_electricidad*0.5 if consumokwh<=500 & consumokwh!=.
	//replace gasto_electricidad_newFS = gasto_electricidad if gasto_electricidad>=191500 & gasto_electricidad<=.
	
//replace gasto_electricidad_newFS = 0 if gasto_electricidad_newFS == .

	gen monto_sub_andeFS = gasto_electricidad - gasto_electricidad_newFS
	
	rename monto_sub_andeFS monto_sub_andeFS_pc
	
	gen porc_sub = gasto_electricidad_newFS/gasto_electricidad
	
	local new = _N + 98
	set obs `new'
	
	forval i = 18168/18265 {
	 replace famunit = "new`i'" in `i'
	}
	
	gen id = _n

	
	*save "$data_pry\data_prep_individuo_elect_2020.dta", replace
	tempfile  data_prep_individuo_elect_2020
	save `data_prep_individuo_elect_2020'
} // close doande


