*===============================================================================
// Paraguay Master Simulation Tool
// Authors: Paul Corral, Gabriela Farfan, Lyliana Gayoso, & Flavia Sacco 
*===============================================================================
set more off
clear all

//if (upper("`c(username)'")!="WB378870"){
*	if (upper("`c(username)'")=="WB334916") global path "C:\Users\\`c(username)'\OneDrive - WBG\WB_GF\2.PovLAC\LC7_PY\4.CEQ\3. PySim2016\PySimTool\"
*	else global path "C:\Users\\`c(username)'\WBG\Maria Gabriela Farfan Betran - LC7_PY\4.CEQ\3. PySim2016\PySimTool\"
//}
//else{
 global path "C:\Users\wb265416\OneDrive - WBG\Documents\PySimTool\"
 else global path "C:\Users\\`c(username)'\WBG\Maria Gabriela Farfan Betran - LC7_PY\4.CEQ\3. PySim2016\PySimTool\"
//}

*===============================================================================
//------------------------------------------------------------------------------
// DO NOT MODIFY BEYOND THIS POINT
//------------------------------------------------------------------------------
*===============================================================================
global data_pry "$path\1.Data"
global indivdta "$data_pry\data_prep_individuo.dta"
global xls_pry  "$path\3.Tool\PYsim_output.xls"
global irpfxl   "$data_pry\irpf.xlsx"
global thedo    "$path\\2.dofiles" 
global theado   "$thedo\1.adofiles\"                

*===============================================================================
// Run necessary ado files
*===============================================================================
import excel using "$xls_pry", sheet(nonprog_tax) first clear
levelsof _ref, local(_ref)
global doref_ `_ref'

*local files : dir "$theado" files "*.ado"
*foreach f of local files{
*qui:cap run "$theado\\`f'"
*}
adopath + "$thedo\1.adofiles\"

*===============================================================================
// 0. Pull Macros
*===============================================================================
run "$thedo\0 - pullmacros.do"

*===============================================================================
// 0.1 Top Incomes...
*===============================================================================
if ($addtop==1) run "$thedo\01 - topincs.do"

*===============================================================================
// 1. Call data
*===============================================================================
run "$thedo\1 - Datacall.do"
if ($simyear>2016){ // Income adjust - only if different from 2016
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
run "$thedo\4 - Tax deductions.do"
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
// 7. Net income of IRP
*===============================================================================
if ($ded_after==0) run "$thedo\7.1 - net income of IRP.do" //Current
else               run "$thedo\7.2 - net income of IRP.do" //Proposed

*===============================================================================
// 8. Efectos indirectos ISC 2012
*===============================================================================
run "$thedo\8.1 - indirectos_iva_2012.do"
run "$thedo\8.2 - indirectos_isc_2012.do"
run "$thedo\8.3 - gasto_neto.do"



*===============================================================================
// 9. Efectos indirectos ISC 2019
*===============================================================================


run "$thedo\9.1 - indirectos_iva_2019.do"
run "$thedo\9.2 - indirectos_isc_2019.do"


run "$thedo\9.3 - indirectos_isc_reforma.do"
run "$thedo\9.4 - gasto_reforma.do"


*===============================================================================
// 10. Efectos indirectos reforma
*===============================================================================
run "$thedo\10.1 - indirectos_iva5.do"
run "$thedo\10.2 - indirectos_iva10.do"

 
run "$thedo\10.3 - indirectos_isc2019_combustibles.do"
run "$thedo\10.4 - indirectos_isc2019_bebidas.do"
run "$thedo\10.5 - indirectos_isc2019_cigarrillos.do"


               
run "$thedo\10.6 - indirectos_isc_combustibles.do" 
run "$thedo\10.7 - indirectos_isc_bebidas.do"   
run "$thedo\10.8 - indirectos_isc_cigarrillos.do" 
run "$thedo\10.9 - gasto_choques.do" 
*===============================================================================
// 11. Costpush
*===============================================================================

run "$thedo\11- imputacion_dmatch.do"


*===============================================================================
// 12. Final income aggregation
*===============================================================================

run "$thedo\998 - final income aggregation.do"


*===============================================================================
// 13. Process outputs
*===============================================================================
run "$thedo\999 - proc simulation.do"

*===============================================================================
// Launch Excel
*===============================================================================
shell ! "$xls_pry"

*===============================================================================
// Exit Stata
*===============================================================================

exit, clear STATA
