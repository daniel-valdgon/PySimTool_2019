

//Macros
local sub2020 $sub2020
local sub2021_1 $sub2021_1
local sub2021_2 $sub2021_2
local sub2021_3 $sub2021_3

* Para el 2020, el subsidio era de 100% exoneracion de pago de Consumo para hogares que consumen menos de 500 KWH

if  ($simyear== 2020){

use "C:\Users\recal\Desktop\PySimTool\1.Data\data_prep_individuo_elect.dta", clear


	if ($doande== 1) {

	gen gasto_electricidad_new = gasto_electricidad*`sub2020' if consumokwh<500 & consumokwh!=.
	gen monto_sub_ande = gasto_electricidad - gasto_electricidad_new
	
	save "C:\Users\recal\Desktop\PySimTool\1.Data\data_prep_individuo_elect_2020.dta", replace

} // close doande


} // close year 2020

