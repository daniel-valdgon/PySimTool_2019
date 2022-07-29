*===============================================================================
// MACROS
*===============================================================================
local _nonprog  $nonprog
local _bracket  $bracket
local _min_wage $min_wage

foreach x of local _bracket{
	foreach y in min max rate{
		local _`y'_t_`x' = ${`y'_t_`x'}
	}
}


*===============================================================================
// Brackets - only if estimated before applying deductions
*===============================================================================

	gen paga_sin_deduccion = pre_deduction >= ((`_min_wage')*`_min_t_1')
	gen trate = .
	foreach x of local _bracket{
		local minth = (`_min_wage')*`_min_t_`x''
		local maxth = (`_min_wage')*`_max_t_`x''
		dis(`minth')
		replace trate = (`_rate_t_`x''/100) if inrange(pre_deduction,`minth',`maxth')			
	}		

	lab var trate "Tax rate according to income bracket - current system"
	lab var paga_sin_deduccion "Has income above minimum threshold - current system"

