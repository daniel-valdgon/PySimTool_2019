clear 
set more off

//Authors: Paul Corral & Flavia Sacco
//Do file creates outputs for excel file

*===============================================================================
// Macros for HHlevel
*===============================================================================
if ($doref_==1) local shname _ref
else local shname


if ($ded_after==0) local tax labor_tax_pc  tot_pit_pc tot_deduction_taken_pc monto_iva_pc monto_isc_pc  ssc_pc tot_dit_corp_pc iragro_pc iracis_pc irpc_pc tot_ire_pc monto_shock_pc monto_nafta_pc
else               local tax  labor_tax_pc tot_deduction_taken_pc  monto_iva_pc monto_isc_pc ssc_pc uprod_tax_pc tot_ire_pc  monto_shock_pc monto_nafta_pc monto_shock_dir_pc monto_shock_indir_pc ///
					         dividendo_tax_pc alquiler_tax_pc tot_pit_pc tot_dit_pc tot_dit_corp_pc ///
							 iragro_pc iracis_pc monto_carne_pc monto_strans_pc monto_sotros_pc monto_fuel_pc monto_diesel_pc
							 
local transfers   tekopora_inc_pc famassist_inc_pc adulto_inc_pc agtrans_inc_pc elec_sub_pc transporte_sub_pc senavitat_sub_pc becas_pc edupubpreesc_pc ///
				edupubprim_pc edupubsec_pc edupubuni_pc transfood_pc transutil_pc adultomayor_uni_pc monto_sub_andeFS_pc_pc monto_tekopora_pc monto_adulto_pc  ///
				monto_becmed_pc monto_becsup_pc monto_transesp_pc monto_transutil_pc monto_pyty1_pc monto_pyty2_pc monto_nangareko_pc  saludpub_pc saludips_pc  


				
				
local incomes   gross_mkt_inc_pc net_mkt_income_pc net_mkt_incirp_pc net_mkt_inc_irpssc_pc dis_inc_pc cons_inc_pc cons_inc_ande_pc final_inc_pc nso_inc 
//local int_lines _190 _320 _550 _2170


local poverty_lines linpobto linpobex
local poverty_incs  gross_mkt_inc_pc net_mkt_income_pc net_mkt_incirp_pc net_mkt_inc_irpssc dis_inc_pc cons_inc_pc cons_inc_ande_pc final_inc_pc nso_inc poverty_ande


local region dpto

local concs `tax' `transfers' `incomes'

*===============================================================================
// Macros for individual level
*===============================================================================
* pot_grav_ind: indicator if ingreso gravable >0
* pago_irp: indicator if irp tax>0
* deductible irp: gasto deducible segun EIG - valor anual a nivel de hogar (ok to collapse mean at individual level??)
* pre_deduction: ingreso gravable - in new system is only employed and cta propia 
*===============================================================================

if ($ded_after==0){
	local contri pot_grav_ind pago_irp  pago_iva  pago_corp pago_iragro pago_iracis pago_irpc pago_iva pago_ire recibe_tekopora recibe_adultomayor recibe_adultouni recibe_ande_pandemia
	local impuestos_pag labor_tax minwage_1 minwage_2 minwage_3 minwage_4 minwage_5
}
else{
	local contri pot_grav_ind pago_labor pago_uprod pago_alquiler pago_dividendo pago_irp pago_iva pago_dit pago_corp pago_iragro pago_iracis pago_ire recibe_tekopora recibe_adultomayor recibe_adultouni recibe_ande_pandemia
	local impuestos_pag labor_tax alquiler_tax dividendo_tax uprod_tax minwage_1 minwage_2 minwage_3 minwage_4 minwage_5 
}


*===============================================================================
// Individual level stats
*===============================================================================
*use "$data_pry\indiv_level_sim.dta", clear //Indiv level output

use `indiv_level_sim'  , clear
drop edad_range 
egen edad_range = cut(p02), at(0(5)105) label
recode edad_range (1=0) 
replace edad_range = edad_range - 1 if edad_range>0
recode edad_range (6 7 8 = 6) (9 10 11 = 7)
replace edad_range = 8 if edad_range>8
lab def edad_range1 0 "[0-9]" 1 "[10-15)" 2 "[15-20)" 3 "[20-25)" 4 "[25-30)" 5 "[30-35)" 6 "[35-50)"  7 "[50-65)" 8 "[65+)"
lab val edad_range edad_range1

replace pre_deduction = . if pre_deduction==0	//income before deductions
clonevar minimo_deducible = deductible_irp		//deductible income from EIG - before substracting iva
clonevar max_deducible = deductible_irp			
clonevar max_prededuction = pre_deduction		



//Effective rate calculation  //For direct taxes only
if ($ded_after==1){
	clonevar tot_inc_labor = pre_deduction
	foreach x in labor_tax alquiler_tax dividendo_tax uprod_tax{
		local nm = subinstr("`x'","_tax","",.)
		gen eff_rate_`x' = `x'/tot_inc_`nm'
		replace eff_rate_`x' = . if eff_rate_`x'==0
	}
	
	gen double eff_rate_iragro= iragro/baseiragro
	replace eff_rate_iragro=. if eff_rate_iragro==0
	
	gen double eff_rate_iracis = iracis/baseiracis
	replace eff_rate_iracis=. if eff_rate_iracis==0
	
	egen double eff_rate_irp = rsum(labor_tax alquiler_tax dividendo_tax)
	replace eff_rate_irp = . if eff_rate_irp==0
	replace eff_rate_irp = eff_rate_irp/taxable_income_irp
	
	egen double eff_rate_total = rsum(labor_tax alquiler_tax dividendo_tax uprod_tax iragro iracis) //Hemos dejado con todo
	replace eff_rate_total = . if eff_rate_total==0
	replace eff_rate_total = eff_rate_total / taxable_income 		
}
else{
	gen double eff_rate_labor_tax = labor_tax/taxable_income if labor_tax!=0
	
	gen double eff_rate_iragro = iragro/baseiragro
	replace eff_rate_iragro=. if eff_rate_iragro==0
	
	gen double eff_rate_iracis = iracis/baseiracis
	replace eff_rate_iracis=. if eff_rate_iracis==0
	
	gen double eff_rate_irpc= irpc/baseirpc
	replace eff_rate_irpc=. if eff_rate_irpc==0
	
	egen double eff_rate_total = rsum(labor_tax iragro iracis irpc)
	replace eff_rate_total = . if eff_rate_total==0
	replace eff_rate_total= eff_rate_total/taxable_income
}
	
xtile decilipcm1= nso_inc [w=fex], nq(10)

preserve
groupfunction [aw=fex], sum(`contri' `impuestos_pag') by(edad_range)
drop if edad_range==.
tempfile edad_range
save `edad_range'
restore

preserve 
groupfunction [aw=fex], mean(porc_sub) by(decilipcm1)
tempfile subande
save `subande'
restore

groupfunction [aw=fex], sum(`contri' `impuestos_pag')  min(minimo_deducible) mean(deductible_irp pre_deduction eff_rate*) max(max_deducible max_prededuction med_prop_gasto_formal) xtile(gross_mkt_inc_pc) nq(10)

append using `edad_range'
append using `subande'
export excel "$xls_pry", sheet(indiv_`shname') sheetreplace first(variable)


*===============================================================================
// Bring in HH level data
*===============================================================================
*use "$data_pry\net_incs.dta", clear

use `net_incs'  , clear
*===============================================================================
//concentration curves		// explain code
							
*===============================================================================
foreach x of local concs{
	covconc `x' [aw=popw] , rank(gross_mkt_inc_pc)	
	local _`x' = r(conc)
}

groupfunction [aw=popw], sum(`concs') by(gross_cent) norestore		//sheet concentration does not seem to have totals, but shares
	qui count
	local _1 =r(N)
	local nnn=`_1'+ 1
	set obs `nnn'
	replace gross_cent = 0 in `nnn'

	sort gross_cent
	putmata x = (`concs') if gross_cent!=0, replace
	mata: x = J(1,cols(x),0) \ x
	mata: x = x:/quadcolsum(x)
	mata: for(i=1; i<=cols(x);i++) x[.,i] = quadrunningsum(x[.,i])
	
	getmata (`concs') = x, replace
	
	qui count
	local _1 =r(N)
	local nnn=`_1'+ 1
	set obs `nnn'
	
	replace gross_cent = 999 in `nnn'
	foreach x of local concs{
		replace `x' = `_`x'' in `nnn'
	}	
order gross_cent, first
export excel using "$xls_pry", sheet(concentration`shname') sheetreplace first(variable)


*===============================================================================
		*Netcash Position
*===============================================================================
	use `net_incs'  , clear
	
		foreach x in `tax'  {
			gen share_`x'_pc= -`x'/gross_mkt_inc_pc
		}		
	
		foreach x in `transfers'   {
			gen share_`x'_pc= `x'/gross_mkt_inc_pc
		}
		
		*replace share_snit_hh_ae = - share_snit_hh_ae
		*keep gross_mkt_qtiles_pc share* FACTOR	
		keep gross_mkt_deciles_pc share* popw
		
	*groupfunction [aw=FACTOR], mean (share*) by(gross_mkt_qtiles_pc) norestore
	groupfunction [aw=popw], mean (share*) by(gross_mkt_deciles_pc ) norestore
	
	*reshape long share_, i(gross_mkt_qtiles_pc) j(variable) string
	reshape long share_, i(gross_mkt_deciles_pc) j(variable) string
	gen measure = "netcash" 
		rename share_ value
	rename 	gross_mkt_deciles_pc decs
	*rename gross_mkt_qtiles_pc gross_mkt_deciles_pc     // not  a big deal latter we define the strings number based on deciles not quintiles 
	tempfile netcash
	save `netcash'	




*===============================================================================
//Gini and Theil
*===============================================================================
*use "$data_pry\net_incs.dta", clear
use `net_incs'  , clear
gen all = 1


sp_groupfunction [aw=popw], gini(`poverty_incs' `tax_inc' `tra_inc') theil(`poverty_incs' `tax_inc' ) by(all) 

tempfile ginidata
save `ginidata'

*===============================================================================
/*poverty - rates by lines specified under povertyline, 
  coverage - proportion of population in the group for which the component is different than 0
  beneficiaries - Number of individuals in households receiving or payer in the group (pop expanded)
  benefits - Total amount paid or received by those in the group (pop expanded)
  dependency - ratio between component specified under "dependency" and component 
	specified under "dependency_d", if conditional is specified numerators equal to 0 are not included
  
*/
*===============================================================================
*use "$data_pry\net_incs.dta", clear
use `net_incs'  , clear

gen decs = ceil(gross_cent/10)

xtile decilipcm = nso_inc [w=fex], nq(10)

preserve
	sp_groupfunction [aw=popw], poverty(`poverty_incs' `tax_inc' `tra_inc') povertyline(`poverty_lines') ///
	by(decs) mean(`concs') coverage(`concs') benefits(`tax' `transfers' `incomes') ///
	beneficiaries(`tax' `transfers') dependency(`concs') dependency_d(`poverty_lines' `incomes') conditional
	gen conditional = "yes" if measure=="dependency"
	tempfile cond
	save `cond'	
restore

	
sp_groupfunction [aw=popw], dependency(`concs') dependency_d(`poverty_lines' `incomes') by(decs)
	gen conditional = ""
	append using `cond'


tempfile mystats
save `mystats'
keep if regexm(measure,"fgt")==1
groupfunction [aw=_population], mean(value) rawsum(_population) by(measure variable reference)

append using `mystats'
append using `ginidata'
append using `netcash'

gen concat = variable +"_"+ measure+"_" +reference+"_"+string(decs)+conditional
order concat, first


//Added to provide indication on type of simulation made
count
local _nob = r(N)

local ded_after  $ded_after
local totalsim ded_after
local a = `_nob'+1
foreach x of local totalsim{
	set obs `a'
	replace concat  = "`x'" in `a'
	replace variable = "``x''" in `a'
	local ++a
	
}

export excel "$xls_pry", sheet(all`shname') sheetreplace first(variable)



