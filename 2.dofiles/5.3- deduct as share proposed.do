*===============================================================================
// MACROS
*===============================================================================
local _dedT = $dedT
local _mytopincs $mytopincs
*===============================================================================

	clonevar _mycheck = deduction_left			//saves deduction pool before substracting deductions
	clonevar _mylab_inc = t_lab_inc				//saves taxable labor income before substracting deductions
	gen double __y = t_lab_inc * (nopaga==0)
	
	
	foreach x of local _mytopincs{
		gen double _x = __y *(__y<=`_dedT') ///
		+ (__y - `_dedT' - deduction_left)*(__y >= (deduction_left +`_dedT')) ///
		+ 0*(__y <(`_dedT' + deduction_left) & __y>`_dedT') if topinc==`x' 

		replace deduction_left = deduction_left - (__y - _x) if topinc==`x' & deduction_left>0
		replace deduction_left = 0 if deduction_left<0
		
		//Deduction left is the same for the whole famunit
		egen double _x1 = min(deduction_left), by(famunit)
		replace deduction_left = _x1
		
		replace __y = _x if topinc==`x' & __y>=0 & !missing(_x)
		drop _x _x1
	}
	
	drop topinc deduction_left
	gen double tot_deduction_taken = pre_deduction - __y if nopaga==0 

	replace t_lab_inc = __y
	drop __y

	lab var t_lab_inc "Taxable labor income net of deductions"
	lab var tot_deduction_taken "Deduction taken by the individual"
