*===============================================================================
// MACROS
*===============================================================================
local _irpftile $irpftile
foreach x of local _irpftile{
	foreach y in min_tinc max_tinc sh_ded mu_ded max_ded{
		local _`y'`x' = ${`y'`x'}
	}
}
*===============================================================================


*===============================================================================
//Adjust consumption deduction
*===============================================================================
*deductmod2=1: consumption deductions adjusted based on share of consumption/income from admin
*deductmod2=3: assignes random draw from consumption deductions reported in admin

*We keep the max value btw 'new adjusted deduction' and original value from EIG
*===============================================================================

	if ($deductmod2==3) set seed 21613648
	gen irpf_20 		= 0
	gen inc_share       = 0
	gen _ded            = 0
	gen double _v       = 0
	
	foreach x of local _irpftile{	
		replace irpf_20 		= `x' if inrange((pre_deduction*12/1e6),`_min_tinc`x'',`_max_tinc`x'')
		if ($deductmod2==1) 	replace inc_share 		= `_sh_ded`x'' if irpf_20==`x'
		if ($deductmod2==3)	    replace _ded 			= min(exp(rnormal()*ln(`_mu_ded`x'')), `_max_ded`x'') if irpf_20==`x'
	}
	
	if ($deductmod2==1) replace _v =  inc_share*pre_deduction if ~missing(inc_share)
	if ($deductmod2==3) replace _v =  _ded*1e6/12             if ~missing(_ded)
	
	egen hhv = sum(_v), by(famunit)
	replace deduction_left = max(hhv, deduction_left)
	drop _v irpf_20 inc_share _ded hhv 

		lab var deduction_left "Deduction pool - adjusted for admin"



