*===============================================================================
// MACROS
*===============================================================================
local _dedT = $dedT
local _mytopincs $mytopincs
local _dedtype $dedtype
local _`_dedtype' ${`_dedtype'}
*===============================================================================

	clonevar _mycheck = deduction_left		//saves deduction pool before substracting deductions
	clonevar _mylab_inc = t_lab_inc			//saves taxable labor income before substracting deductions 
	
	//All others share deduction
	foreach x of local _mytopincs{
		gen _x  = (t_lab_inc - min(deduction_left,`_value'/12))*(t_lab_inc > min(deduction_left,`_value'/12)) ///
		+ (0)*(t_lab_inc<=min(deduction_left,`_value'/12)) if topinc==`x' & deduction_left>0 
		
		replace deduction_left = deduction_left - (t_lab_inc - _x) if topinc==`x' & deduction_left>0 
		replace deduction_left = 0 if deduction_left<0 
		
		//Deduction left is the same for the whole famunit
		egen double _x1 = min(deduction_left), by(famunit)
		replace deduction_left = _x1 
		
		replace t_lab_inc = _x if topinc==`x' & t_lab_inc>=0 & !missing(_x) 
		drop _x _x1
	}
	drop topinc deduction_left
	gen tot_deduction_taken = 0
	replace tot_deduction_taken = pre_deduction	- t_lab_inc if pre_deduction>=($min_t_1*$min_wage)

	lab var t_lab_inc "Taxable labor income net of deductions"
	lab var tot_deduction_taken "Deduction taken by the individual"
