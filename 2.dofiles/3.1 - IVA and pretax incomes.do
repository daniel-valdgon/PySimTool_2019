*===============================================================================
// MACROS
*===============================================================================
local _dedtype $dedtype
local _`_dedtype' ${`_dedtype'}
local _vat $VAT

dis as error("running old system 3.1 dofile")
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
local other_mkt_incs `alquiler' `dividendo' `agro'; 

//Non categorized market income;
local jefe_incs
e01kjde;

//Imputed rents;
local imp_rent
v19ede;

// Private transfers;
local private_transfers 
e01fde
e02l1bde
e02l2bde
;

//Other transfer incomes: e01ide(Tekopora), e01gde(divorcio o cuidado de hijos) e01kde(AM) e01lde(viveres de otras instituciones pub);
local transfers
e01ide
e01gde
e01kde
e01lde;

//These are labor income in NET of SSC (changed in SSC.do);
local mis_ing 
e01aimdeb2 
e01bimdeb2 
e01cimde;

local _all_incomes mis_ing labor_incs pension_inc other_mkt_incs private_transfers jefe_incs transfers imp_rent;

#delimit cr 


*===============================================================================
// IVA deductions...
*===============================================================================
		
	gen double deductible_irp=ipcm*med_prop_gasto_formal*totpers*12	
	gen double deductible_iva=ipcm*med_prop_gasto_trabajo*totpers*12
		label var deductible_irp "Expenses deductible from IRP - formal expenses - hh level"
		label var deductible_iva "Expenses deductible of IVA - work expenses - hh level"
	
	rename grava_irp1 g_e01aimdeb2
	rename grava_irp2 g_e01bimdeb2
	rename grava_irp3 g_e01cimde
	
	rename grava_iva1 i_e01aimdeb2
	rename grava_iva2 i_e01bimdeb2
	gen i_e01cimde = 0

*===============================================================================
// Get pretaxable income
*===============================================================================
//Note that variables g_`x' are created before hand in 
	//Pre tax income (After SSC)
	egen double lab_inc_pretax = rsum(`mis_ing')
		lab var lab_inc_pretax "Pre tax LABOR income (After SSC)"
	
	//Get taxable incomes
	//For those who pay iva salarios we first net income from that tax
	gen double t_lab_inc = 0
		lab var t_lab_inc "Taxable income before deductions - includes capital in current system"
	foreach x of local mis_ing{
		replace t_lab_inc = `x'*(g_`x'==1 & i_`x'!=1) + t_lab_inc if ~missing(`x') 
	}

	gen double iva_inc = 0
	foreach x of local mis_ing{
		replace iva_inc = `x'*(1/(1+(`_vat'/100)))*(i_`x'==1) + iva_inc if ~missing(`x') 
	}
		lab var iva_inc "Taxable income net of IVA deduction (if subject to IVA)"

	egen double share_iva = sum((!missing(iva_inc) & iva_inc!=0)/totpers), by(famunit)
		lab var share_iva "Share of HH members who pay IVA salario"
	gen hhpayIVA = share_iva!=0
		lab var hhpayIVA "Household has a member that pays IVA salario"
	gen paga_iva = !missing(iva_inc) & iva_inc!=0
		lab var paga_iva "Individual pays IVA salario"
	
	gen double diff_pretax_taxable = lab_inc_pretax - t_lab_inc - iva_inc
		lab var diff_pretax_taxable "LABOR income not subject to IRP"

	egen double capital_incs = rsum(`capital_incs')
		lab var capital_incs "Capital incomes"

	replace t_lab_inc = t_lab_inc + capital_incs if ~missing(capital_incs) 
	replace t_lab_inc = t_lab_inc + iva_inc if ~missing(iva_inc)
		
	gen nopaga=(t_lab_inc==0|missing(t_lab_inc))
		lab var nopaga "Individual w/o income subject to IRP"
		
*===============================================================================
//Let's add other incomes
*===============================================================================

	egen double pension_inc = rsum(`pension_inc')
		lab var pension_inc "Pension and retirement incomes"
	gen agro_inc = `agro'
		lab var agro_inc "Other income from agro"
	rename `imp_rent' rent_inc
		lab var rent_inc "Imputed rent income"
	egen transfer_inc = rsum(`transfers')
		lab var transfer_inc "Income from transfers"
	


