*===============================================================================
// Paraguay Master Simulation Tool
// Authors: Paul Corral, Gabriela Farfan, Lyliana Gayoso, & Flavia Sacco 
*===============================================================================
set more off
clear all
macro drop _all
//if (upper("`c(username)'")!="WB378870"){
//	if (upper("`c(username)'")=="WB334916") global path "C:\Users\\`c(username)'\OneDrive - WBG\WB_GF\2.PovLAC\LC7_PY\4.CEQ\3. PySim2016\PySimTool\"
//	else global path "C:\Users\wb484435\OneDrive - WBG\Maria Gabriela Farfan Betran - 1.3.PEB\Maria Gabriela Farfan Betran - LC7_PY\4.CEQ\5. PySim 2019\PySimTool\"
//}
//else{
	//global path "C:\Users\WB378870\Documents\PySimTool\"
//}

*qui {

if "`c(username)'"=="WB547455"  {
	global path "C:\Users\wb547455\WBG\Luis Bernardo Recalde Ramirez - 01 - PySimTool\PySimTool_2019"
} 

else {
	global path "C:\Users\recal\Desktop\PySimTool"
}

*===============================================================================
//------------------------------------------------------------------------------
// DO NOT MODIFY BEYOND THIS POINT
//------------------------------------------------------------------------------
*===============================================================================
global data_pry "$path\1.Data"
*global indivdta "$data_pry\data_prep_jp.dta"
global indivdta "$data_pry\data_prep_individuo.dta"
global xls_pry  "$path\3.Tool\PYsim_new.xlsx"
global irpfxl   "$data_pry\irpf.xlsx"
global thedo    "$path\\2.dofiles" 
global theado   "$thedo\1.adofiles\"                
global datagini "$path\1.Data"

*===============================================================================
// Run necessary ado files
*===============================================================================
import excel using "$xls_pry", sheet(nonprog_tax) first clear
levelsof _ref, local(_ref)
global doref_ `_ref'

local files : dir "$theado" files "*.ado"
foreach f of local files{
	display("`f'")
	qui:cap run "$theado\\`f'"
}

*===============================================================================
// 0. Pull Macros
*===============================================================================
run "$thedo\0 - pullmacros.do"


*===============================================================================
// 0.1 Top Incomes...
*===============================================================================
if ($addtop==1) include "$thedo\01 - topincs.do"

*===============================================================================
// 1. Call data
*===============================================================================
include "$thedo\1 - Datacall.do"

if ($simyear>2019 ){ // Income adjust - only if different from 2016
	run "$thedo\1.1 - income adjust.do"
	if ($deductmod!=4 | $deductmod2!=4){
		run "$thedo\1.2 - income adjust-admin.do"
	}	
}

*===============================================================================
// 2. SSC
*===============================================================================
run "$thedo\2 - SSC.do"


*===============================================================================
// 3. IVA and Pre-Tax Incomes
*===============================================================================
if ($ded_after==0) run "$thedo\3.1 - IVA and pretax incomes.do"
else 			   run "$thedo\3.2 - IVA and pretax incomes new system.do"

*===============================================================================
// 4. Tax deductions
*===============================================================================
include "$thedo\4 - Tax deductions.do"
if ($deductmod2!=4) run "$thedo\4.1 - adjust consumption deductions.do" // Adjusting expenditure deduction, only if requested in the tool
if ($deductmod!=4) run "$thedo\4.2 - investment deductions.do" // Adjust deduction amounts, add the investment deduction -- only if requested in the tool

*===============================================================================
// 5. Applying the deductions - Multiple branches
*===============================================================================
levelsof topinc, local(_mytopincs)
global mytopincs `_mytopincs'

if ($ded_after==0){  //CURRENT
	if (lower("$dedtype")=="share") run "$thedo\5.1 - deduct as share current.do"
	else                            run "$thedo\5.2 - deduct as value current.do"
}
else{ //PROPOSED
	if (lower("$dedtype")=="share") run "$thedo\5.3- deduct as share proposed.do"
	else 							run "$thedo\5.4 - deduct as value proposed.do"
}


*===============================================================================
// 6. Apply tax system
*===============================================================================
if ($ded_after==0){ //Current
	run "$thedo\6.1 - Apply brackets before.do"
	run "$thedo\6.2 - nonprog tax estimation.do"
}
else{ //Proposed
	run "$thedo\6.3 - prog tax estimation.do"
	run "$thedo\6.4 - uprod & capital taxes.do"
}


*===============================================================================
// 7. Social Transfers 
*===============================================================================

run "$thedo\social_transfers\becas_media.do"

run "$thedo\social_transfers\becas_superior.do"

run "$thedo\social_transfers\alimentacion_escolar.do"

run "$thedo\social_transfers\utiles_escolares.do"

run "$thedo\social_transfers\nangareko_pytyvo.do"

run "$thedo\social_transfers\tekopora_adulto.do"


*===============================================================================
// 7. Net income of IRP
*===============================================================================
if ($ded_after==0) { //Current 
 include "$thedo\7.1 - net income of IRP.do" 
 }
else { //Proposed
 include "$thedo\7.2 - net income of IRP.do" 
 
* include "$thedo\7.3 - gini estimates.do"
}              

tempfile part_I
 
save `part_I'


 
*****************************
*  Impuestos al consumo y fuels 
*****************************

*1. Indirect effects 

include "$thedo\IVA_indirects.do"

*include "$thedo\net_down\indirect_effects_fuels_utilities.do"

*1. Indirect effects fuel shock 

include "$thedo\fuel_indirects.do"



*3. Direct effects 

include "$thedo\IVA_direct.do"

**************************
* Imputacion 
************************** 


use  `part_I'   , clear 
 
rename imputed_vat_v1 hhid 
 
merge m:1 hhid using `cons_tax' , keepusing(ratio_iva total_iva)
 
keep if _merge==3
 
drop _merge
 
drop hhid



rename imputed_isc_v1 hhid 
 
merge m:1 hhid using `cons_tax' , keepusing(ratio_isc total_isc)
 
keep if _merge==3
 
drop _merge
 
drop hhid


rename imputed_nafta_v1 hhid 
 
merge m:1 hhid using `cons_tax' , keepusing(ratio_fuels ratio_nafta   ratio_fuels_dir ratio_fuels_indir ratio_sotros ratio_stransporte ratio_carne)
 
keep if _merge==3
 
drop _merge
 
drop hhid


rename imputed_diesel_v1 hhid 
 
merge m:1 hhid using `cons_tax' , keepusing(ratio_diesel ratio_dir_diesel)
 
keep if _merge==3
 
drop _merge
 
drop hhid



tempfile    indiv_level_sim
save       `indiv_level_sim'


*===============================================================================
// 8. Efectos indirectos ISC 2012
*===============================================================================
*include "$thedo\8.1 - indirectos_iva_2012.do"
*include "$thedo\8.2 - indirectos_isc_2012.do"
*include "$thedo\8.3 - gasto_neto.do"


*===============================================================================
// 9. Efectos indirectos ISC 2019
*===============================================================================


*include "$thedo\9.1 - indirectos_iva_2019.do"
*include "$thedo\9.2 - indirectos_isc_2019.do"


*include "$thedo\9.3 - indirectos_isc_reforma.do"
*include "$thedo\9.4 - gasto_reforma.do"


*===============================================================================
// 10. Efectos indirectos reforma
*===============================================================================
*include "$thedo\10.1 - indirectos_iva5.do"
*include "$thedo\10.2 - indirectos_iva10.do"

 
*include "$thedo\10.3 - indirectos_isc2019_combustibles.do"
*include "$thedo\10.4 - indirectos_isc2019_bebidas.do"
*include "$thedo\10.5 - indirectos_isc2019_cigarrillos.do"



               
*include "$thedo\10.6 - indirectos_isc_combustibles.do" 
*include "$thedo\10.7 - indirectos_isc_bebidas.do"   
*include "$thedo\10.8 - indirectos_isc_cigarrillos.do" 
*include "$thedo\10.9 - gasto_choques.do" 
*===============================================================================
// 11. Costpush
*===============================================================================

*include "$thedo\11- imputacion_dmatch.do"
*include "$thedo\11.1 - imputacion_dmatch_adj.do"

*===============================================================================
// 12. ANDE subsidy
*===============================================================================
if ($simyear == 2020) {
include "$thedo\997 - subsidio ande 2020.do"
}

if ($simyear == 2021) {
include "$thedo\997 - subsidio ande 2021.do"
}


*===============================================================================
// 13. Final income aggregation
*===============================================================================

include "$thedo\998 - final income aggregation_jp.do"

*===============================================================================
// 14. Process outputs
*===============================================================================
include "$thedo\999 - proc simulation.do"

*===============================================================================
// Launch Excel
*===============================================================================



shell ! "$xls_pry"
