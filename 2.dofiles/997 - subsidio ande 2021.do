

//Macros
local sub2020 $sub2020
local sub2021_1 $sub2021_1
local sub2021_2 $sub2021_2
local sub2021_3 $sub2021_3
local th1 $th1
local th2 $th2
local th3 $th3

* Para el 2021, el subsidio va por rangos : 1) 75% de subsidio para hogares que consumen entre 1-100 KWH
*											2) 50% de subsidio para hogares que consumen entre 101-200 KWH
* 											3) 25% de subsidio para hogares que consumen entre 201-300 KWH


use "$data_pry\data_prep_individuo_elect.dta", clear

	if ($doande== 1){
	
	xtile decilipcm = ipcm [w=fex], nq(10)


** Generating beneficiaries

capture drop bene_ande1
gen          bene_ande1=. 
replace bene_ande1=1 if (gasto_electricidad<=38700)
replace bene_ande1=2 if (gasto_electricidad>38700 & gasto_electricidad<=77400)
replace bene_ande1=3 if (gasto_electricidad>77400 & gasto_electricidad<=116100)

//capture drop bene_ande
gen bene_ande=(bene_ande1>0 & bene_ande1!=.)


** Generating ammount of benefits

capture drop monto_sub_ande1
gen                      monto_sub_ande1=gasto_electricidad*0.75 if bene_ande1==1
replace monto_sub_ande1=gasto_electricidad*0.5 if bene_ande1==2
replace monto_sub_ande1=gasto_electricidad*0.25 if bene_ande1==3
replace monto_sub_ande1=0 if bene_ande1==.


table  decilipcm bene_ande [w=fex] , c( mean monto_sub_ande1 sum monto_sub_ande1 ) row col  //* lo que pasa es que el consumo de los deciles menores es MUCHO menor que 191500, entonces el beneficio es mayor para los de mas arriba*/

* Numero de hogares por decil 
capture drop decilipcmh
xtile       decilipcmh=ipcm if jefe==1 [w=fex], nq(10)

*shares 
capture drop sh_monto
gen sh_monto=monto_sub_ande1/gasto_electricidad
table decilipcmh [w=fex] if bene_ande==1, c(mean monto_sub_ande1  mean sh_monto mean gasto_electricidad freq) row col

preserve
cd "$path\3.Tool\"

*xtable decilipcmh if bene_ande==1 [w=fex] , c( sum monto_sub_ande1 freq mean sh_monto ) format(%9.3f) sc filename("PYsim.xls") sheet("ande_new2021", replace) modify
restore	



	preserve 
	drop if bene_ande!=1
	collapse (mean) sh_monto (sum) monto_sub_ande1 (count) bene_ande [w=fex], by(decilipcmh)
	export excel "$xls_pry", sheet(indiv_ande) sheetreplace first(variable)

	restore

	
	gen gasto_electricidad_newFS = gasto_electricidad*0.75 if consumokwh>1 & consumokwh<=100 & consumokwh!=. 
	replace gasto_electricidad_newFS = gasto_electricidad*0.5 if consumokwh>100 & consumokwh<=200 & consumokwh!=.
	replace gasto_electricidad_newFS = gasto_electricidad*0.25 if consumokwh>200 & consumokwh<=300 & consumokwh!=.
	//replace gasto_electricidad_new = gasto_electricidad if consumokwh>300 & consumokwh!=.
	
	gen monto_sub_andeFS = gasto_electricidad - gasto_electricidad_newFS 
	
	rename monto_sub_andeFS monto_sub_andeFS_pc
	
	gen porc_sub = gasto_electricidad_new/gasto_electricidad
	
	local new = _N + 98
	set obs `new'
	
	forval i = 18168/18265 {
	 replace famunit = "new`i'" in `i'
	}
	
	gen id = _n
	
		
	
	*save "$data_pry\data_prep_individuo_elect_2021.dta", replace
	tempfile  data_prep_individuo_elect_2021
	save `data_prep_individuo_elect_2021'
	
	} // close do ande
