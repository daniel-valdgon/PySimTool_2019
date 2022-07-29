*===============================================================================
// MACROS
*===============================================================================
local _prog_rates $rate
local _prog_mins  $prog_mins
*===============================================================================

	//Progressive marginal tax rates
	dirtax t_lab_inc, grossinput rates(`_prog_rates') tholds(`_prog_mins') gen(net_lab_inc)		
	gen double labor_tax = t_lab_inc - net_lab_inc		

	
	lab var labor_tax "Labor tax"
	lab var net_lab_inc "Labor income net of direct taxes"
