*===============================================================================
// MACROS
*===============================================================================
local _irpftile $irpftile

foreach x of local _irpftile{
	foreach y in min_tinc max_tinc sh_ded mu_ded max_ded sh_invest sh_inv_cons mu_invest max_invest{
		local _`y'`x' = ${`y'`x'}
	}
}
*===============================================================================

*===============================================================================
// Adjust deduction amounts, add the investment deduction
*===============================================================================
*deductmod=1: adds investment deductions based on share of investment/income from admin
*deductmod=2: adds investment deductions based on share of investment/total deduction from admin
*deductmod=3: assignes random draw from investment deductions reported in admin

*we add investment deductions to each household member
*we keep the maximum level of deductions within the household, and assign that value to all household members
*===============================================================================

	if ($deductmod==3){
		set seed 6413667
		//sort famunit l02
	}
	gen irpf_20 		= 0
	gen invest 			= 0
	gen invest_sh 		= 0
	gen invest_cons_sh  = 0

	foreach x of local _irpftile{	
		replace irpf_20 		= `x' if inrange((pre_deduction*12/1e6),`_min_tinc`x'',`_max_tinc`x'')

		if ($deductmod==1) 	replace invest_sh 		= `_sh_invest`x'' if irpf_20==`x'
		if ($deductmod==2)  replace invest_cons_sh  = `_sh_inv_cons`x'' if irpf_20==`x'
		if ($deductmod==3)	replace invest 			= min(exp(rnormal()*ln(`_mu_invest`x'')), `_max_invest`x'') if irpf_20==`x'
	}

	if ($deductmod==1) replace deduction_left = deduction_left + invest_sh*pre_deduction if ~missing(invest_sh) & ~missing(pre_deduction)
	if ($deductmod==2) replace deduction_left = deduction_left*(1+invest_cons_sh)        if ~missing(invest_cons_sh)
	if ($deductmod==3) replace deduction_left = deduction_left + invest*1e6/12           if ~missing(invest)
	
	drop irpf_20 invest invest_sh invest_cons_sh
	
	egen double _1 = max(deduction_left), by(famunit)
	replace deduction_left = _1
	drop _1
		lab var deduction_left "Deduction pool - adjusted for admin"


