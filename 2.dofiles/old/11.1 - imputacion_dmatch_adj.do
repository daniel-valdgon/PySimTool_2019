*===============================================================================
// MACROS PARA AJUSTAR LOS SHARES A 2017-2019
*===============================================================================

if $simyear!=2016 {
local _simyear = $simyear
local _adj`_simyear' = ${adj`_simyear'}
}

*use "$data_pry\gasto_imputado_dmatch.dta", clear

use   `gasto_imputado_dmatch'  , clear
		
	//Ajustamos los montos y gastos para IVA e ISC para los anos 2017-2019

if $simyear!=2016 	{
	
foreach x of varlist monto_iva_hogar monto_iva_total monto_iscRE_hogar monto_iscRE_total monto_isc2019_hogar monto_isc2019_total {
		replace `x' = `x'*`_adj`_simyear''
		}
}


*save "$data_pry\gasto_imputado_dmatchadj.dta", replace

tempfile   gasto_imputado_dmatchadj
save      `gasto_imputado_dmatchadj'