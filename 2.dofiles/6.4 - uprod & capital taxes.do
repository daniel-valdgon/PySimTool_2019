*===============================================================================
// MACROS
*===============================================================================
//Calculate tax for new system for Unidad productiva and capital
local pr_rent 	= $pr_rent		//Renta presunta por capital
local r_rent  	= $r_rent		//tasa aplicada a renta presunta por capital
local dividend	= $dividend		//tasa de dividendos

local lhs tot_inc_uprod

*===============================================================================

gen double uprod_tax=0

foreach x of global bracket2{
	local min = ${min2_`x'}/12
	local max = ${max2_`x'}/12
	replace uprod_tax = ${amt2_`x'}/12 if inrange(`lhs', `min', `max') & !missing(`lhs') & `lhs'>0
}

replace uprod_tax = (`lhs'*(1-($deduct2/100)))*($rate2/100) if `lhs'>`max' & ~missing(`lhs')
	lab var uprod_tax "Tax unidad productiva"

//Alquiler
gen double alquiler_tax  =  ((`pr_rent'/100)*tot_inc_alquiler)*(`r_rent'/100)
gen double dividendo_tax =  tot_inc_dividendo*(`dividend'/100) 
	lab var alquiler_tax "Tax from rent"
	lab var dividendo_tax "Tax from dividends"

	
dis as error("running new system 6.4 dofile")	