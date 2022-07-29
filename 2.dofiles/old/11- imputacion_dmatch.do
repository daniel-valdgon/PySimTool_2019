*==================================================================================================
* PYSim2016
* Programa de Estimacion de Imputacion de Gasto 
* Survey to Survey Imputation --distribution match (dmatch ado)
*================================================================================================
set more off


use "$data_pry\base_imputacion_eig12.dta", clear
	*merge 1:1 famunit using "$data_pry\shares.dta", nogen 
	merge 1:1 famunit using `shares', nogen 
	
	append using "$data_pry\base_imputacion_eph16.dta", gen(enemdu)
	gen rural=(area==6)
	
	#d ;
	
	
	//Restriccion sobre el share de gasto sobre ingreso
	keep if shg_obs <=3 | shg_obs ==.	

	;
	#d

	
	//Ingreso del hogar siempre va primero
	local impvar ingreso_hh16 sh_gasto shg_iva5 shg_iva10 shg_isc_otros shg_combRE shg_bebRE shg_cigRE
	             shg_comb19 shg_beb19 shg_cig19 sh_iva5 sh_iva10 sh_isc_otros sh_combRE 
				 sh_bebRE sh_cigRE sh_comb19 sh_beb19 sh_cig19 gasto_base
	;
	#d cr
	
	
	tabstat sh_gasto shg_iva5 shg_iva10 shg_isc_otros shg_combRE shg_bebRE shg_cigRE            ///
			sh_iva5 sh_iva10 sh_isc_otros sh_combRE sh_bebRE sh_cigRE                           ///
			shg_comb19 shg_beb19 shg_cig19 sh_comb19 sh_beb19 sh_cig19 gasto_base, by(enemdu)
	
	
	dmatch `impvar',  uniqid(hhid) trimup(99) todata(enemdu) 

	tabstat sh_gasto shg_iva5 shg_iva10 shg_isc_otros shg_combRE shg_bebRE shg_cigRE      ///
			sh_iva5 sh_iva10 sh_isc_otros sh_combRE sh_bebRE sh_cigRE                    ///
			shg_comb19 shg_beb19 shg_cig19 sh_comb19 sh_beb19 sh_cig19 gasto_base, by(enemdu)
		 
		
	//Variables a precios del 2016 en base a proporcion del gasto base no del ingreso 
	gen gasto_2019        = ingreso_hh16*sh_gasto
	gen monto_iva5        = gasto_2019*shg_iva5
	gen monto_iva10       = gasto_2019*shg_iva10
	gen monto_isc_otros   = gasto_2019*shg_isc_otros
	
	gen monto_ISCcomb19   = gasto_2019*shg_comb19
	gen monto_ISCbeb19    = gasto_2019*shg_beb19
	gen monto_ISCcig19    = gasto_2019*shg_cig19
	gen monto_totalISC_19 = monto_ISCcomb19 + monto_ISCbeb19 + monto_ISCcig19
		
	gen monto_ISCcomb     = gasto_2019*shg_combRE
	gen monto_ISCbeb      = gasto_2019*shg_bebRE
	gen monto_ISCcig      = gasto_2019*shg_cigRE
	gen monto_totalISC_RE = monto_ISCcomb + monto_ISCbeb + monto_ISCcig

	
	keep  famunit decil fex rural dptorep gasto_* monto* ingreso_hh16 total_miembros enemdu base_eph
	order famunit decil fex rural dptorep
	
	label var gasto_base        "Gasto base"
	label var gasto_2019        "Gasto base imputado"
	label var monto_iva5        "IVA pagado tasa 5%" 
	label var monto_iva10       "IVA pagado tasa 10%" 
	label var monto_ISCcomb19   "ISC pagado combustibles - 2019"
	label var monto_ISCbeb19    "ISC pagado bebidas - 2019"
	label var monto_ISCcig19    "ISC pagado cigarrillos - 2019"
	label var monto_totalISC_19 "Total ISC pagado - 2019"
	label var monto_ISCcomb     "ISC pagado combustibles - Reforma"
	label var monto_ISCbeb      "ISC pagado bebidas - Reforma"
	label var monto_ISCcig      "ISC pagado cigarrillos - Reforma"
	label var monto_totalISC_RE "Total ISC pagado - Reforma"
	label var famunit           "Identificador del hogar"
	label var rural             "1 - rural, 0 - urbana"
	label var dptorep           "departamentos representativos"
	label var total_miembros    "cantidad miembros del hogar"
	label var ingreso_hh16      "Ingreso total del hogar a precios 2016"
	
	//Recaudacion total ISC otros bienes no afectados por la reforma
	//(este no varia, es el mismo en el 2019 y en la reforma)
	egen monto_isc_otros_total = total(monto_isc_otros*fex)
	
	//Recaudacion total de ISC por grupo de bienes
	egen monto_isc_com19 = total(monto_ISCcomb19*fex)
	egen monto_isc_beb19 = total(monto_ISCbeb19*fex)
	egen monto_isc_cig19 = total(monto_ISCcig19*fex)
	
	egen monto_isc2019_total = rsum(monto_isc_com19 monto_isc_beb19 monto_isc_cig19 monto_isc_otros_total) //recaudacion total isc 2019

	//Monto pagado por hogar
	egen monto_isc2019_hogar = rsum(monto_ISCcomb19 monto_ISCbeb19 monto_ISCcig19 monto_isc_otros)  //monto total pagado ISC 2019

	//Recaudacion total de ISC por grupo de bienes
	egen monto_isc_comRE = total(monto_ISCcomb*fex)
	egen monto_isc_bebRE = total(monto_ISCbeb*fex)
	egen monto_isc_cigRE = total(monto_ISCcig*fex)

	egen monto_iscRE_total = rsum(monto_isc_comRE monto_isc_bebRE monto_isc_cigRE monto_isc_otros_total) //recaudacion total isc reforma

	//Monto pagado por hogar
	egen monto_iscRE_hogar = rsum(monto_ISCcomb monto_ISCbeb monto_ISCcig monto_isc_otros)  //monto total pagado por hogar ISC reforma

	//Recaudacion total IVA
	egen monto_iva5_total = total(monto_iva5*fex)
	egen monto_iva10_total = total(monto_iva10*fex)

	egen monto_iva_total = rsum(monto_iva5_total  monto_iva10_total)

	//Monto pagado por hogar
	egen monto_iva_hogar = rsum(monto_iva5 monto_iva10)       //monto pagado de iva por hogar


	keep if enemdu==1
		
	
	*save "$data_pry\gasto_imputado_dmatch.dta", replace 
	tempfile gasto_imputado_dmatch
	save    `gasto_imputado_dmatch'