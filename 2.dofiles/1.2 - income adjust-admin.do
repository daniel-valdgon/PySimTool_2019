
*===============================================================================
// MACROS
*===============================================================================
local _simyear = $simyear
local _adj`_simyear' = ${adj`_simyear'}
local _irpftile $irpftile //this local saved ventiles from 0-pullmacros.do

	foreach x of local _irpftile{
		local _mu_ded_tot`x'  = ${mu_ded_tot`x'} 		//Mean total deduction
		local _mu_invest`x'   = ${mu_invest`x'}			//Mean investment deduction 
		local _sh_invest`x'   = ${sh_invest`x'}			//Share of investment/income
		local _sh_inv_cons`x' = ${sh_inv_cons`x'}		//Share of investment/total deduction
		local _sh_ded`x'      = ${sh_ded`x'}			//Share of consumption/income
		local _mu_ded`x'      = ${mu_ded`x'}			//Mean consumption deduction
			local _max_tinc`x'    = ${max_tinc`x'}		//Max income in ventil
			local _max_invest`x'  = ${max_invest`x'}	//Max investment deduciton in ventil
			local _max_ded_tot`x' = ${max_ded_tot`x'}	//Max total deduction in ventil
			local _max_ded`x'     = ${max_ded`x'}		//Max consumption deduction in ventil
			
			local _min_tinc`x'    = ${min_tinc`x'}		//Min income in ventil
	}


*===============================================================================
// for simulation years adjust all incomes
*===============================================================================
	foreach x of local _irpftile{
		global min_tinc`x'   = `_min_tinc`x''*`_adj`_simyear''
			global max_tinc`x'   = `_max_tinc`x''*`_adj`_simyear''
		global mu_ded_tot`x' = `_mu_ded_tot`x''*`_adj`_simyear'' 
			global max_ded_tot`x' = `_max_ded_tot`x''*`_adj`_simyear''
		global mu_invest`x'  = `_mu_invest`x'' *`_adj`_simyear''
			global max_invest`x' = `_max_invest`x''*`_adj`_simyear''
		global mu_ded`x'     = `_mu_ded`x''*`_adj`_simyear''
		global max_ded`x'    = `_max_ded`x''*`_adj`_simyear''
	}
