* PYSim2016
* Programa de Calculo de Base de Datos para Simulaciones de Impuestos Indirectos
* Version: Noviembre 2019
* Autora: Lyliana Gayoso de Ervin
*===================================================================================================================
clear
set more off

/*=======================================================
             Unir base gasto c/ efectos indirectos                                            
=========================================================*/

*use "$data_pry\IT_base_gastos_reforma_hogar.dta", clear

use `IT_base_gastos_reforma_hogar'   , clear

replace isc_cat=. if isc_cat==3

keep famunit fex decil quintil ipcm total_miembros isc* iva*  sectorio sectorioe ga01c ga01e ///
     gasto_compra gasto_compra_neto3 gasto_compra19_3 formal2 ingreso_hh* isc_cat

/*   Recodificacion de sectores IO */

//SECTORES CREADOS PARA CAPTURAR DIFERENTES TASAS DE IVA

replace sectorio = 41 if sectorio==1  & iva19==5
replace sectorio = 42 if sectorio==2  & iva19==5
replace sectorio = 43 if sectorio==5  & iva19==5
replace sectorio = 44 if sectorio==6  & iva19==5
replace sectorio = 45 if sectorio==8  & iva19==5
replace sectorio = 46 if sectorio==15 & iva19==0
replace sectorio = 47 if sectorio==19 & iva19==5
replace sectorio = 48 if sectorio==34 & iva19==0
replace sectorio = 49 if sectorio==40 & iva19==0
replace sectorio = 50 if sectorio==40 & iva19==5

*merge m:1 sectorio using "$data_pry\efectos_iva5.dta"

merge m:1 sectorio using    `efectos_iva5'
drop if _merge==2   // eliminamos efectos para sectores no existentes en la base de gastos 
drop _merge

*merge m:1 sectorio using "$data_pry\efectos_iva10.dta"
merge m:1 sectorio using  `efectos_iva10'

drop if _merge==2   // eliminamos efectos para sectores no existentes en la base de gastos 
drop _merge

replace sectorio = 1  if sectorio==41 & iva19==5
replace sectorio = 2  if sectorio==42 & iva19==5
replace sectorio = 5  if sectorio==43 & iva19==5
replace sectorio = 6  if sectorio==44 & iva19==5
replace sectorio = 8  if sectorio==45 & iva19==5
replace sectorio = 15 if sectorio==46 & iva19==0
replace sectorio = 19 if sectorio==47 & iva19==5
replace sectorio = 34 if sectorio==48 & iva19==0
replace sectorio = 40 if sectorio==49 & iva19==0
replace sectorio = 40 if sectorio==50 & iva19==5

//SECTORES CREADOS PARA CAPTURAR DIFERENTES TASAS DE ISC 
replace sectorio = 41 if sectorio==9  & isc19<=5  & isc19!=0
replace sectorio = 42 if sectorio==9  & isc19>5   & isc19!=0
replace sectorio = 43 if sectorio==16 & isc19==24 
replace sectorio = 44 if sectorio==16 & isc19==34 
replace sectorio = 45 if sectorio==16 & isc19==38 
replace sectorio = 46 if sectorio==16 & isc19==18 
replace sectorio = 47 if sectorio==19 & isc19==0 
replace sectorio = 48 if sectorio==34 & isc19==10

*merge m:1 sectorio using "$data_pry\efectos_isc_combustibles_2019.dta"

merge m:1 sectorio using `efectos_isc_combustibles_2019'
drop if _merge==2   // eliminamos efectos para sectores no existentes en la base de gastos 
drop _merge

*merge m:1 sectorio using "$data_pry\efectos_isc_bebidas_2019.dta"
merge m:1 sectorio using  `efectos_isc_bebidas_2019'
drop if _merge==2   // eliminamos efectos para sectores no existentes en la base de gastos 
drop _merge

*merge m:1 sectorio using "$data_pry\efectos_isc_cigarrillos_2019.dta"

merge m:1 sectorio using `efectos_isc_cigarrillos_2019'
drop if _merge==2   // eliminamos efectos para sectores no existentes en la base de gastos 
drop _merge

*merge m:1 sectorio using "$data_pry\efectos_isc_combustibles_reforma.dta"

merge m:1 sectorio using `e_isc_combustibles_reforma'
drop if _merge==2   // eliminamos efectos para sectores no existentes en la base de gastos 
drop _merge

*merge m:1 sectorio using "$data_pry\efectos_isc_bebidas_reforma.dta"

merge m:1 sectorio using  `efectos_isc_bebidas_reforma'
drop if _merge==2   // eliminamos efectos para sectores no existentes en la base de gastos 
drop _merge

*merge m:1 sectorio using "$data_pry\efectos_isc_cigarrillos_reforma.dta"

merge m:1 sectorio using `efectos_isc_cigarrillos_reforma'
drop if _merge==2   // eliminamos efectos para sectores no existentes en la base de gastos 
drop _merge

replace sectorio = 9  if sectorio==41 & isc19<=5  & isc19!=0
replace sectorio = 9  if sectorio==42 & isc19>5   & isc19!=0
replace sectorio = 16 if sectorio==43 & isc19==24 
replace sectorio = 16 if sectorio==44 & isc19==34 
replace sectorio = 16 if sectorio==45 & isc19==38 
replace sectorio = 16 if sectorio==46 & isc19==18 
replace sectorio = 19 if sectorio==47 & isc19==0
replace sectorio = 34 if sectorio==48 & isc19==10

/*===========================================================
              Calculo de Gasto e Impuesto Pagado 
	     Escenario 3 considerando choques individuales                                            
=============================================================*/
//En este paso aplicamos los choques aislados para obtener el monto pagado de impuesto
//gasto compra a tasas vigentes del 2019 = gasto_compra19_3

rename gasto_compra19_3   gasto_compra_2019
rename gasto_compra_neto3 gasto_neto 


/*------------------------------------------------------------------
 1 - Neteamos gasto por impuesto pagado por IVA 5 % e IVA 10%
-------------------------------------------------------------------*/
//En este paso queremos netear el gasto de IVA. Utilizamos la formula (tasa iva /(1 + tasa iva))
//Por ejemplo, si la tasa de IVA es 10%, para obtener el monto de IVA pagado, se multiplica gasto por 10/110
//o su equivalente, 1/1.1. 

gen monto_iva5 = gasto_compra_2019*(iva19 + indirect_iva5_11)/(iva19 + indirect_iva5_11 + 1) if iva19==5 & formal2==1 //bienes gravados formales, 1ra y 2nda ronda
replace monto_iva5 = gasto_compra_2019*((indirect_iva5_10)/(indirect_iva5_10+1)) if iva19==0 //bienes exentos formales e informales
replace monto_iva5 = gasto_compra_2019*((indirect_iva5_10)/(indirect_iva5_10+1)) if iva19!=5 //bienes gravados sin iva 5%
replace monto_iva5 = gasto_compra_2019*((indirect_iva5_10 + indirect_iva5_11)/(indirect_iva5_10 + indirect_iva5_11 +1)) if iva19==5 & formal2==0 //bienes gravados informales

gen monto_iva10 = gasto_compra_2019*((iva19 + indirect_iva10_11)/(iva19 + indirect_iva10_11 + 1)) if iva19==10 & formal2==1 //bienes gravados formales, 1ra y 2nda ronda
replace monto_iva10 = gasto_compra_2019*(indirect_iva10_10/(indirect_iva10_10 + 1)) if iva19==0 //bienes exentos formales e informales
replace monto_iva10 = gasto_compra_2019*(indirect_iva10_10/(indirect_iva10_10 + 1)) if iva19!=10 //bienes gravados sin IVA 10%
replace monto_iva10 = gasto_compra_2019*((indirect_iva10_10  + indirect_iva10_11)/(indirect_iva10_10  + indirect_iva10_11 +1)) if iva19==10 & formal2==0 //bienes gravados informales

gen gasto_sin_iva   = gasto_compra_2019 - monto_iva5 - monto_iva10


/*--------------------------------------------------------------
 2 - Obtenemos el ISC pagado en otros bienes
---------------------------------------------------------------*/
gen monto_isc_otros = gasto_sin_iva*((isc19/100 + indirect_isc19C_11*(-1))/(isc19/100 + indirect_isc19C_11*(-1) + 1)) if sectorio!=9 & sectorio!=10 & sectorio!=16 & isc19!=0
replace monto_isc_otros = gasto_sin_iva*((indirect_isc19C_10*(-1))/(indirect_isc19C_11*(-1) + 1)) if sectorio!=9 & sectorio!=10 & sectorio!=16 & isc19==0

/*--------------------------------------------------------------
 3 - Gasto y monto de impuesto pagado en 2019 
---------------------------------------------------------------*/

//COMBUSTIBLES
gen monto_isc_C19     = gasto_sin_iva*(isc19/100 + indirect_isc19C_11*(-1))/(isc19/100 + indirect_isc19C_11*(-1)+1) if sectorio==16 & isc19!=0
replace monto_isc_C19 = gasto_sin_iva*(indirect_isc19C_10*(-1))/(indirect_isc19C_10*(-1)+1)                 if sectorio==16 & isc19==0 
replace monto_isc_C19 = 0 if sectorio!=16


//BEBIDAS
gen monto_isc_B19     = gasto_sin_iva*(isc19/100 + indirect_isc19B_11*(-1))/(isc19/100 + indirect_isc19B_11*(-1)+1) if sectorio==9 & isc19!=0
replace monto_isc_B19 = gasto_sin_iva*(indirect_isc19B_11*(-1))/(indirect_isc19B_11*(-1)+1)                 if sectorio==9 & isc19==0
replace monto_isc_B19 = 0 if sectorio!=9

//CIGARRILLOS
gen     monto_isc_CIG19 = gasto_sin_iva*(isc19/100 + indirect_isc19CIG_11*(-1))/(isc19/100 + indirect_isc19CIG_11*(-1)+1) if sectorio==10 & isc19!=0
replace monto_isc_CIG19 = gasto_sin_iva*(indirect_isc19CIG_10*(-1))/(indirect_isc19CIG_10*(-1)+1)                 if sectorio==10 & isc19==0
replace monto_isc_CIG19 = 0 if sectorio!=10

gen gasto_sin_CBC19 = gasto_sin_iva - monto_isc_C19 - monto_isc_B19 -monto_isc_CIG19

/*--------------------------------------------------------------
 4 - Gasto y monto de impuesto pagado en Reforma
---------------------------------------------------------------*/

//COMBUSTIBLES
gen monto_isc_CRE     = gasto_sin_iva*(isc_max/100 + indirect_iscC_11)/(isc_max/100 + indirect_iscC_11+1) if sectorio==16 & isc_max!=0
replace monto_isc_CRE = gasto_sin_iva*(indirect_iscC_10)/(indirect_iscC_10+1)                             if sectorio==16 & isc_max==0 
replace monto_isc_CRE = 0 if sectorio!=16

//BEBIDAS
gen monto_isc_BRE     = gasto_sin_iva*(isc_max/100 + indirect_iscB_11)/(isc_max/100 + indirect_iscB_11+1)   if sectorio==9 & isc_max!=0
replace monto_isc_BRE = gasto_sin_iva*(indirect_iscB_10)/(indirect_iscB_10 +1)                  if sectorio==9 & isc_max==0
replace monto_isc_BRE = 0 if sectorio!=9

//CIGARRILLOS
gen     monto_isc_CIGRE = gasto_sin_iva*(isc_max/100 + indirect_iscCIG_11)/(isc_max/100 + indirect_iscCIG_11+1) if sectorio==10 & isc_max!=0
replace monto_isc_CIGRE = gasto_sin_iva*(indirect_iscCIG_10)/(indirect_iscCIG_10+1)               if sectorio==10 & isc_max==0
replace monto_isc_CIGRE = 0 if sectorio!=10

gen gasto_sin_CBCRE = gasto_sin_iva - (monto_isc_CRE - monto_isc_C19) - (monto_isc_BRE - monto_isc_B19) + (monto_isc_CIGRE - monto_isc_CIG19)
	
groupfunction, sum(gasto_neto gasto_compra gasto_compra_2019  monto_isc* monto_iva* gasto_sin_*) mean(ingreso_hh16 ingreso_hh12 total_miembros ipcm fex decil quintil) by(famunit)

rename gasto_sin_CBC19 gasto_base 

gen shg_obs = gasto_compra / ingreso_hh12

gen shg_iva5   = monto_iva5 / gasto_base
gen shg_iva10  = monto_iva10 / gasto_base 
gen shg_isc_otros = monto_isc_otros / gasto_base 

gen sh_iva5   = monto_iva5 / ingreso_hh16
gen sh_iva10  = monto_iva10 / ingreso_hh16
gen sh_isc_otros = monto_isc_otros / ingreso_hh16

gen shg_combRE = monto_isc_CRE / gasto_base
gen shg_bebRE  = monto_isc_BRE / gasto_base
gen shg_cigRE  = monto_isc_CIGRE / gasto_base 

gen sh_combRE = monto_isc_CRE / ingreso_hh16
gen sh_bebRE  = monto_isc_BRE / ingreso_hh16
gen sh_cigRE  = monto_isc_CIGRE / ingreso_hh16 

gen shg_comb19 = monto_isc_C19 / gasto_base
gen shg_beb19  = monto_isc_B19 / gasto_base
gen shg_cig19  = monto_isc_CIG19 / gasto_base

gen sh_comb19 = monto_isc_C19 / ingreso_hh16	
gen sh_beb19  = monto_isc_B19 / ingreso_hh16
gen sh_cig19  = monto_isc_CIG19 / ingreso_hh16 

gen sh_gasto = gasto_base/ ingreso_hh16 

sum sh_*

tab decil [w=fex], sum(monto_iva5)
tab decil [w=fex], sum(monto_iva10)

tab decil [w=fex], sum(shg_iva5)
tab decil [w=fex], sum(shg_iva10)
tab decil [w=fex], sum(sh_iva5)
tab decil [w=fex], sum(sh_iva10)

tab decil [w=fex], sum(monto_isc_C19)
tab decil [w=fex], sum(monto_isc_B19)
tab decil [w=fex], sum(monto_isc_CIG19)
tab decil [w=fex], sum(gasto_base)

tab decil [w=fex], sum(monto_isc_CRE)
tab decil [w=fex], sum(monto_isc_BRE)
tab decil [w=fex], sum(monto_isc_CIGRE)
tab decil [w=fex], sum(gasto_sin_CBCRE)

tab decil [w=fex], sum(shg_comb19)
tab decil [w=fex], sum(shg_beb19)
tab decil [w=fex], sum(shg_cig19)

tab decil [w=fex], sum(shg_combRE)
tab decil [w=fex], sum(shg_bebRE)
tab decil [w=fex], sum(shg_cigRE)

tab decil [w=fex], sum(sh_comb19)
tab decil [w=fex], sum(sh_beb19)
tab decil [w=fex], sum(sh_cig19)

tab decil [w=fex], sum(sh_combRE)
tab decil [w=fex], sum(sh_bebRE)
tab decil [w=fex], sum(sh_cigRE)

tab decil [w=fex], sum(sh_gasto)

gen base_eph = 2012

keep famunit base_eph decil shg_obs sh_gasto shg_iva5 shg_iva10 sh_iva5 sh_iva10 shg_combRE shg_bebRE shg_cigRE sh_combRE sh_bebRE sh_cigRE ///
                      shg_comb19 shg_beb19 shg_cig19 sh_comb19 sh_beb19 sh_cig19 sh_isc_otros shg_isc_otros gasto_base total_miembros ingreso_hh*

tempfile   shares
save  `shares'
					  
					  
*save "$data_pry\shares.dta", replace

