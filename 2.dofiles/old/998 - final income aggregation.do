clear
set more off

//Author: Flavia Sacco
//Do file creates the additional income concepts that are part of the CEQ, 
//to be included in the excel tool

*use "$data_pry\indiv_level_sim.dta", clear

use  `indiv_level_sim'  , clear


*===============================================================================
// MACROS
*===============================================================================
local _min_wage $min_wage
local _salud    $salud

*===============================================================================

//Income classification locals
#delimit;

//Labor incomes - individual level - as reported in survey;
local labor_incs 
e01aimde 
e01bimde 
e01cimde;

//Pension and retirement incomes;
local pension_inc
e01hde
e01jde; 

//Capital incomes;
local alquiler 
e01dde; 
local dividendo 
e01ede;
local capital_incs `alquiler' `dividendo';

//Other market incomes from agro;
local agro 
e01mde; 

// All other market incomes;
local other_mkt_incs  `agro'; 

//Non categorized market income;
local jefe_incs
e01kjde;

//Imputed rents;
local imp_rent
v19ede;

// Private transfers;
local private_transfers 
e01fde
e02tde
e01gde
;



//Ingresos para iragro, iracis, irpc
local ing_dirtax 
iragro
iracis
irpc;

//Other transfer incomes: e01ide(Tekopora), e01gde(divorcio o cuidado de hijos) e01kde(AM) e01lde(viveres de otras instituciones pub);
local transfers
e01ide
e01kde
e01lde;
	
//These are labor income in NET of SSC (changed in SSC.do);
local mis_ing 
e01aimdeb2 
e01bimdeb2 
e01cimde;


local adulto_uni
adultomayor_uni;

local _all_incomes mis_ing labor_incs pension_inc other_mkt_incs private_transfers jefe_incs transfers imp_rent ing_dirtax adulto_uni ;

#delimit cr 


*================================================================================================
// Bring data for income calculations, based on the identification of benefits made in data_prep
*================================================================================================

//Use indiv_level database saved in 7.1 and 7.2
*use "$data_pry\indiv_level_sim.dta", clear 

use `indiv_level_sim'  , clear 

// Do files 7.1 & 7.2 have computed net_mkt_inc_irp and taxable_income, now we add all other CEQ incomes

	
//Net mkt income (from other direct taxes)

if ($ded_after==0) {

gen double net_mkt_income = net_mkt_incirp - iragro if ~missing(iragro)
replace net_mkt_income =    net_mkt_income    - iracis if ~missing(iracis)
replace net_mkt_income =    net_mkt_income    - irpc   if ~missing(irpc)
replace net_mkt_income =    net_mkt_income    - ssc if ~missing(ssc) //net of pension contributions

}
//New system does not include IRPC anymore, this was substituted by Regimen SIMPLE (programmed as unidad productiva)
else {     
gen double net_mkt_income = net_mkt_incirp - iragro if ~missing(iragro)
replace net_mkt_income =    net_mkt_income   - iracis if ~missing(iracis)
replace net_mkt_income =    net_mkt_income   - uprod_tax if ~missing(uprod_tax)
replace net_mkt_income =    net_mkt_income   - ssc if ~missing(ssc) //net of pension contributions

}	
//Disposable  income : net_mkt_inc + direct transfers
    egen double dis_inc= rsum( net_mkt_income `transfers' becas_hh transfood_hh transutil_hh )
	

	//rename some important incomes
	rename e01ide tekopora_inc 
	egen famassist_inc = rsum(`private_transfers')  
	rename e01kde adulto_inc
	rename e01lde agtrans_inc


	gen recibe_tekopora = (tekopora_inc!=0 & ~missing(tekopora_inc)) 
	gen recibe_adultomayor = (adulto_inc!=0 & ~missing(adulto_inc))

	gen recibe_adultouni = (adultomayor_uni!=0 & ~missing(adultomayor_uni))
	
	
		
//	Consumable income: indirect taxes and indirect transfers (subsidies)

*merge m:1 famunit using "$data_pry\gasto_imputado_dmatchadj.dta", keepusing(monto_iva_hogar monto_iscRE_hogar monto_isc2019_hogar)

merge m:1 famunit using `gasto_imputado_dmatchadj' , keepusing(monto_iva_hogar monto_iscRE_hogar monto_isc2019_hogar)
drop _merge

gen monto_iva_pc = monto_iva_hogar/totpers
gen monto_iscRE_pc= monto_iscRE_hogar/totpers
gen monto_isc2019_pc = monto_isc2019/totpers

rename transporte_sub_hh transporteF
rename senavitat senavitatF

if ($ded_after==0) & ($simyear== 2019) {
	
   gen pago_iva = monto_iva_pc !=0 & ~missing(monto_iva_pc)
   gen pago_isc = monto_isc2019_pc !=0 & ~missing(monto_isc2019_pc)
   gen monto_sub_andeFS_pc = .
   gen recibe_ande_pandemia=.
   gen porc_sub =.
   
   egen double cons_inc= rsum( dis_inc elec_sub_hh transporteF senavitatF)
   egen double cons_inc_ande = rsum(dis_inc elec_sub_hh transporteF senavitatF)
   replace cons_inc = cons_inc - monto_iva_pc if ~missing(monto_iva_pc)
   replace cons_inc = cons_inc - monto_isc2019_pc if ~missing(monto_isc2019_pc) 
} // close year 2019

	if ($ded_after==0) & ($simyear == 2020) {
	*merge 1:1 famunit using "$data_pry\data_prep_individuo_elect_2020.dta", keepusing(monto_sub_andeFS_pc porc_sub)
	 merge 1:1 famunit using `data_prep_individuo_elect_2020' , keepusing(monto_sub_andeFS_pc porc_sub)                          
	gen pago_iva = monto_iva_pc !=0 & ~missing(monto_iva_pc)
   gen pago_isc = monto_isc2019_pc !=0 & ~missing(monto_isc2019_pc)

   egen double cons_inc= rsum( dis_inc elec_sub_hh transporteF senavitatF)
   egen double cons_inc_ande = rsum(dis_inc elec_sub_hh transporteF senavitatF monto_sub_andeFS_pc)
   replace cons_inc = cons_inc - monto_iva_pc if ~missing(monto_iva_pc)
   replace cons_inc = cons_inc - monto_isc2019_pc if ~missing(monto_isc2019_pc) 
   
   gen recibe_ande_pandemia = (monto_sub_andeFS_pc>0 & monto_sub_andeFS_pc!=.)
	
	
	} // close year 2020
 
	if ($ded_after==0) & ($simyear == 2021) {
	*merge 1:1 famunit using "$data_pry\data_prep_individuo_elect_2021.dta", keepusing(monto_sub_andeFS_pc porc_sub)
	merge 1:1 famunit using `data_prep_individuo_elect_2021', keepusing(monto_sub_andeFS_pc porc_sub)
	gen pago_iva = monto_iva_pc !=0 & ~missing(monto_iva_pc)
   gen pago_isc = monto_isc2019_pc !=0 & ~missing(monto_isc2019_pc)

   egen double cons_inc= rsum( dis_inc elec_sub_hh transporteF senavitatF)
   egen double cons_inc_ande = rsum(dis_inc elec_sub_hh transporteF senavitatF monto_sub_andeFS_pc)
   replace cons_inc = cons_inc - monto_iva_pc if ~missing(monto_iva_pc)
   replace cons_inc = cons_inc - monto_isc2019_pc if ~missing(monto_isc2019_pc) 
   
   gen recibe_ande_pandemia = (monto_sub_andeFS_pc>0 & monto_sub_andeFS_pc!=.)
	
	
	} // close year 2021

	if ($ded_after==0) & ($simyear == 2022) {
   gen pago_iva = monto_iva_pc !=0 & ~missing(monto_iva_pc)
   gen pago_isc = monto_isc2019_pc !=0 & ~missing(monto_isc2019_pc)
   gen monto_sub_andeFS_pc = .
   gen recibe_ande_pandemia = .
   gen porc_sub = .

   egen double cons_inc= rsum( dis_inc elec_sub_hh transporteF senavitatF)
   egen double cons_inc_ande = rsum(dis_inc elec_sub_hh transporteF senavitatF)
   replace cons_inc = cons_inc - monto_iva_pc if ~missing(monto_iva_pc)
   replace cons_inc = cons_inc - monto_isc2019_pc if ~missing(monto_isc2019_pc) 
	
	} //close year 2022

	
	
if ($ded_after==1) & ($simyear == 2019) { 	
	
	gen pago_iva = monto_iva_pc !=0 & ~missing(monto_iva_pc)
	gen pago_isc = monto_iscRE_pc !=0 & ~missing(monto_iscRE_pc)
	gen monto_sub_andeFS_pc = .
	gen recibe_ande_pandemia = .
	gen porc_sub =. 
	
	egen double cons_inc = rsum( dis_inc elec_sub_hh transporteF senavitatF)
	egen double cons_inc_ande = rsum(dis_inc elec_sub_hh transporteF senavitatF)
	replace cons_inc = cons_inc - monto_iva_pc if ~missing(monto_iva_pc)
	replace cons_inc = cons_inc - monto_iscRE_pc if ~missing(monto_iscRE_pc)   
	} //close year 2019
	
	if ($ded_after==1) & ($simyear == 2020) {
	gen id = _n
	*merge 1:1 id using "$data_pry\data_prep_individuo_elect_2020.dta", keepusing(monto_sub_andeFS_pc porc_sub)
    merge 1:1 id using  `data_prep_individuo_elect_2020', keepusing(monto_sub_andeFS_pc porc_sub)
 
   gen pago_iva = monto_iva_pc !=0 & ~missing(monto_iva_pc)
   gen pago_isc = monto_iscRE_pc !=0 & ~missing(monto_iscRE_pc)

   egen double cons_inc= rsum( dis_inc elec_sub_hh transporteF senavitatF)
   egen double cons_inc_ande = rsum(dis_inc elec_sub_hh transporteF senavitatF monto_sub_andeFS_pc)
   replace cons_inc = cons_inc - monto_iva_pc if ~missing(monto_iva_pc)
   replace cons_inc = cons_inc - monto_iscRE_pc if ~missing(monto_iscRE_pc) 
   
   gen recibe_ande_pandemia = (monto_sub_andeFS_pc>0 & monto_sub_andeFS_pc!=.)
	
	
	} // close year 2020
 
	if ($ded_after==1) & ($simyear == 2021) {
	gen id = _n
	
	*merge 1:1 id using "$data_pry\data_prep_individuo_elect_2021.dta", keepusing(monto_sub_andeFS_pc porc_sub)
   merge 1:1 id using  `data_prep_individuo_elect_2021' , keepusing(monto_sub_andeFS_pc porc_sub)
   
   gen pago_iva = monto_iva_pc !=0 & ~missing(monto_iva_pc)
   gen pago_isc = monto_iscRE_pc !=0 & ~missing(monto_iscRE_pc)

   
   egen double cons_inc= rsum( dis_inc elec_sub_hh transporteF senavitatF)
   egen double cons_inc_ande = rsum(dis_inc elec_sub_hh transporteF senavitatF monto_sub_andeFS_pc)
   
   replace cons_inc = cons_inc - monto_iva_pc if ~missing(monto_iva_pc)
   replace cons_inc = cons_inc - monto_iscRE_pc if ~missing(monto_iscRE_pc) 
	
	gen recibe_ande_pandemia = (monto_sub_andeFS_pc>0 & monto_sub_andeFS_pc!=.)
	
	
	} // close year 2021
	
		
	if ($ded_after==1) & ($simyear == 2022) {
	
   gen pago_iva = monto_iva_pc !=0 & ~missing(monto_iva_pc)
   gen pago_isc = monto_iscRE_pc !=0 & ~missing(monto_iscRE_pc)
   gen monto_sub_andeFS_pc = . 
   gen recibe_ande_pandemia=.
   gen porc_sub =. 
   
   egen double cons_inc= rsum( dis_inc elec_sub_hh transporteF senavitatF)
   egen double cons_inc_ande = rsum(dis_inc elec_sub_hh transporteF senavitatF)
   replace cons_inc = cons_inc - monto_iva_pc if ~missing(monto_iva_pc)
   replace cons_inc = cons_inc - monto_iscRE_pc if ~missing(monto_iscRE_pc) 
	
	} // close year 2022
	
 
//   Final income: final income includes social spending in education, health, and user's tariffs

   egen double final_inc = rsum(cons_inc edupubpreesc_hh edupubprim_hh edupubsec_hh edupubuni_hh saludpub_hh saludips_hh)

	
	lab var net_mkt_income "Market income net of direct taxes & SSC"
	lab var dis_inc "Disposable income - Mk income + direct transfers"
	lab var cons_inc "Consumable income - Dis inc + subsidies - ind taxes"
	lab var final_inc "Final income - Cons inc + social spendings"
	
	lab var tekopora_inc "Tekopora"
	lab var famassist_inc "Private transfers"
	lab var adulto_inc "Adultos mayores"
	lab var agtrans_inc "Transfers agro"
	

	rename _mycheck potential_deduction //deduction pool before deductions
	replace potential_deduction = potential_deduction/totpers //Para asegurarse que se agrege correctamente
	rename elec_sub_hh elec_sub
	rename transporteF transporte_sub
	rename senavitatF senavitat_sub
	rename edupubpreesc_hh edupubpreesc
	rename edupubprim_hh edupubprim
	rename edupubsec_hh edupubsec
	rename edupubuni_hh edupubuni
	rename saludpub_hh saludpub
	rename saludips_hh saludips
	rename becas_hh becas
	rename transfood_hh transfood
	rename transutil_hh transutil
	
	
//Local for current system	and new system (because they have different taxes components)
	if ($ded_after==0) {
	local percap_incs gross_mkt_inc net_mkt_income net_mkt_incirp net_mkt_inc_irpssc dis_inc cons_inc cons_inc_ande final_inc rent_inc tekopora_inc famassist_inc ///
					  adulto_inc labor_tax monto_isc2019_pc monto_iva_pc iragro iracis irpc tot_dit_corp tot_ire agtrans_inc tot_deduction_taken salud_inc ssc potential_deduction taxable_income ///
					  elec_sub transporte_sub senavitat_sub edupubpreesc edupubprim edupubsec edupubuni saludpub saludips becas transfood transutil adultomayor_uni monto_sub_andeFS_pc
}
	
    
	else     {      
	local percap_incs gross_mkt_inc net_mkt_income net_mkt_incirp net_mkt_inc_irpssc dis_inc cons_inc cons_inc_ande final_inc rent_inc tekopora_inc famassist_inc ///
	adulto_inc labor_tax monto_iscRE_pc monto_iva_pc agtrans_inc tot_deduction_taken salud_inc ssc tot_inc_alquiler tot_inc_dividendo ///
	uprod_tax alquiler_tax dividendo_tax tot_pit tot_dit tot_dit_corp tot_ire iragro iracis potential_deduction taxable_income  taxable_income_irp   ///
	elec_sub transporte_sub senavitat_sub edupubpreesc edupubprim edupubsec edupubuni saludpub saludips becas transfood transutil adultomayor_uni monto_sub_andeFS_pc
	}

	
	egen gross_mkt_inc_pc = sum(gross_mkt_inc/totpers), by(famunit)	
		lab var gross_mkt_inc_pc "Gross market income per capita"
	
	local percap: list uniq percap
	
	rename ipcm nso_inc
		lab var nso_inc "IPCM as calculated by DGEEC"
	
*save "$data_pry\indiv_level_sim.dta", replace 

tempfile indiv_level_sim
save `indiv_level_sim'

//Now we collapse to have all income components at the household level

	gen see_fex=fex
	drop gross_mkt_inc_pc	
	groupfunction, first(totpers fex nso_inc linpobto linpobex dpto potencial_grav area dpto p02 p06 rango_ingreso minwage_*) sum(`percap_incs' see_fex) by(famunit)
	foreach x of local percap_incs{
		replace `x' = `x'/totpers
		rename `x' `x'_pc
	}
	
	gen double popw = fex*totpers
	_ebin gross_mkt_inc_pc [aw=popw], nq(100) gen(gross_cent) 

	
	lab var popw "Household population weight"
	lab var fex "Individual population weight"
	lab var gross_cent "Centil of gross market income pc"
	
	
	
	keep famunit *_pc nso_inc gross_cent popw linpobto linpobex dpto totpers fex area dpto p02 p06 rango_ingreso minwage_* 

	egen poverty_ande = rsum(nso_inc monto_sub_andeFS_pc_pc)
	apoverty poverty_ande [w=popw], varpl(linpobto)
	
	//gen recibe_ande_new = (monto_sub_ande_pc_pc>0 & monto_sub_ande_pc_pc!=.)
	
*save "$data_pry\net_incs.dta", replace

tempfile net_incs
save `net_incs'
