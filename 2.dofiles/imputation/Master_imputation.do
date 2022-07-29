*===============================================================================
// Imputation Master 
// Authors: Juan P. Baquero
*===============================================================================
set more off
clear all
macro drop _all
set seed 647


if "`c(username)'"=="WB547455"  {
	global path "C:\Users\wb547455\WBG\Luis Bernardo Recalde Ramirez - 01 - PySimTool\PySimTool_2019"
} 

else {
	global path "C:\Users\recal\Desktop\PySimTool"
}

*===============================================================================

global data_pry "$path\1.Data"
global indivdta "$data_pry\EPH 2019\REG02_EPHC_T4_2019.dta"
global hhdta "$data_pry\EPH 2019\ro1_eph2019.dta"
global agg   "$data_pry\EPH 2019\ingrefam_2019_4t.dta"
global indivdta_eig "$data_pry\EIG\reg02t.dta"
global hogdta_eig "$data_pry\EIG\reg01.dta"
global agg_eig   "$data_pry\EIG\sumaria_hogar.dta"
global xls_pry  "$path\3.Tool\PYsim_new.xlsx"
global irpfxl   "$data_pry\irpf.xlsx"
global thedo    "$path\\2.dofiles" 
global theado   "$thedo\1.adofiles\"                



local files : dir "$theado" files "*.ado"
foreach f of local files{
	display("`f'")
	qui:cap run "$theado\\`f'"
}


// prapair data 

include "$thedo\imputation\EPH_prepair.do"

include "$thedo\imputation\EIG_prepair.do"


// calculate iva in 2019 to generate a link between  egi and eph 

include "$thedo\imputation\IVA_indirects.do"

include "$thedo\imputation\IVA_direct.do"


// imputation 

include  "$thedo\imputation\imputation_egi_to_eph.do"


// store link 

use `imp_vat'  , clear

merge 1:1 upm nvivi nhoga using  `imp_isc'  , nogen

merge 1:1 upm nvivi nhoga using  `imp_nafta'  , nogen

merge 1:1 upm nvivi nhoga using  `imp_diesel'  , nogen


save "$data_pry\egi_eph_link_2019.dta"  , replace    // Hh level 






