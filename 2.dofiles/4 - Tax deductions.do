*===============================================================================
// MACROS
*===============================================================================
local _dedtype $dedtype
local _`_dedtype' ${`_dedtype'}
local _vat $VAT

*===============================================================================
// Deductions
*===============================================================================
* t_lab_inc: Taxable income (net of SSC and net of IVA salario) 
	* in current system: includes all labor income + capital income
	* in new system: includes labor income from employees and cta propia
* If deductions are a share of expenses, the share determines the maximum pool
* If deductions are an absolute maximum, the max times the number of individuals earning taxable income determines the maximum pool
* We calculate the absolute max, therefore not controling for whether individuals earning taxable income are above the minimum threshold
*===============================================================================
	if (lower("`_dedtype'")=="share"){
	gen double deductionirp_pool = deductible_irp*(`_share'/100)/12  //monthly
	dis("`_share'")
	}
	
	else{ //this has to be done by individual who has income
		egen con_ing = sum(~missing(t_lab_inc) & t_lab_inc>0), by(famunit)		
		gen double deductionirp_pool  = min(deductible_irp, `_value'*con_ing) 		
		replace deductionirp_pool = deductionirp_pool/12 //monthly
		//All those values where the min discount is not fullfilled, then households can share the expenses		
		gen belowmax = deductionirp_pool<(`_value'*con_ing/12) if ~missing(deductionirp_pool) //these households share their expenses
			lab var con_ing "Number of household members with taxable labor income"
			lab var belowmax "Household's deductible expenditure higher than legally allowed"
	}
	lab var deductionirp_pool "Deduction pool from EIG - bf netting iva w/o admin adjustment"

	//Get max income earners in HH
	
	*bysort famunit -t_lab_inc: gen topinc = _n
	gsort famunit -t_lab_inc
	by famunit : gen topinc = _n 
	replace topinc=. if t_lab_inc==0|t_lab_inc==.
	levelsof topinc, local(_mytopincs)
		lab var topinc "Orders individuals from highest to lowest income"
	
	gen double deduction_left = deductionirp_pool if hhpayIVA==0
	replace deduction_left    = deductionirp_pool - deductible_iva*(`_vat'/100) if hhpayIVA==1
	replace deduction_left    = 0 if deduction_left<0
		lab var deduction_left "Deduction pool net of iva deductions"
	
	if ("$min_imp"==""){
		egen double potencial_grav = sum((!missing(t_lab_inc) & t_lab_inc!=0)/totpers), by(famunit)
		gen pot_grav_ind = !missing(t_lab_inc) & t_lab_inc!=0 
	}
	else{
		egen double potencial_grav = sum((!missing(t_lab_inc) & t_lab_inc!=0 & nopaga!=1)/totpers), by(famunit)		
		gen pot_grav_ind = !missing(t_lab_inc) & t_lab_inc!=0 & nopaga!=1
	}
		lab var pot_grav_ind   "Has taxable income before applying deductions - above min_imp"
		lab var potencial_grav "Share of tax payers in HH"
		// pot_grav_ind is the opposite as nopaga
		
	clonevar pre_deduction = t_lab_inc
		lab var pre_deduction "Taxable labor income before deductions - only employees or cta ppia if new system"

	sort famunit  l02	
	
