*===============================================================================
// MACROS
*===============================================================================
local _dedT = $dedT
local _mytopincs $mytopincs
local _dedtype $dedtype
local _`_dedtype' ${`_dedtype'}


local _rate $rate
local cual: list posof "0" in _rate 
local mint $min $min_threshold
tokenize `mint'
if (`cual'!=0) local thold = ``=`cual'+1'' / 12
else local thold = 0

*===============================================================================

	clonevar _mycheck = deduction_left	//saves deduction pool before substracting deductions
	
	dis as error "gen descuenta = t_lab_inc>`thold' if !missing(t_lab_inc)"
	gen descuenta = t_lab_inc>`thold' if !missing(t_lab_inc)
	
	clonevar _mylab_inc = t_lab_inc		//saves taxable labor income before substracting deductions
	gen double __y = t_lab_inc * (nopaga==0)

	
	//All others share deduction
	foreach x of local _mytopincs{
	
		gen _x  = (__y - min(deduction_left,`_value'/12))*(__y > min(deduction_left,`_value'/12)) ///
		+ (0)*(__y<=min(deduction_left,`_value'/12)) if topinc==`x' & deduction_left>0 
			
		replace deduction_left = deduction_left - (__y - _x) if topinc==`x' & deduction_left>0 
		replace deduction_left = 0 if deduction_left<0 
		
		//Deduction left is the same for the whole famunit
		egen double _x1 = min(deduction_left), by(famunit)
		replace deduction_left = _x1 
		
		replace __y = _x if topinc==`x' & __y>=0 & !missing(_x)
		drop _x _x1
	}
	drop topinc deduction_left	
	gen double tot_deduction_taken = pre_deduction - __y if descuenta==1 & nopaga==0
	
	replace t_lab_inc = __y
	drop __y

	lab var t_lab_inc "Taxable labor income net of deductions"
	lab var tot_deduction_taken "Deduction taken by the individual"
