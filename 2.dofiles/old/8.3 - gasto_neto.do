* PYSim2016
* Programa de Calculo de Base de Datos para Simulaciones de Impuestos Indirectos
* Version: Noviembre 2019
* Autora: Lyliana Gayoso de Ervin
* TTL: Maria Gabriela Farfan Beltran
* Este do-file estima los montos de impuestos pagados en el 2012 y el gasto neto de impuesto en la EIG 2012
*===================================================================================================================
clear
set more off


use "$data_pry\data_prep_indtaxes.dta", clear

//Locals
local pc_growth  0.233230   //tasa de crecimiento de consumo privado per capita
local pthrough   0.87

//Restringimos base a productos comprados en lugares identificados
keep if formal2!=.

/*=======================================================
             Unir base gasto c/ efectos indirectos                                            
=========================================================*/

/*   Recodificacion de sectores IO */

//SECTORES CREADOS PARA CAPTURAR DIFERENTES TASAS DE IVA

replace sectorio = 41 if sectorio==1  & iva12==5   //Agricultura IVA 5%
replace sectorio = 42 if sectorio==2  & iva12==10  //Caza IVA 10%
replace sectorio = 43 if sectorio==5  & iva12==5   //Carne IVA 5%
replace sectorio = 44 if sectorio==6  & iva12==5   //Molineria IVA 5%
replace sectorio = 45 if sectorio==8  & iva12==5   //Otros alimentos IVA 5%
replace sectorio = 46 if sectorio==15 & iva12==10  //Pulpa IVA 10%
replace sectorio = 47 if sectorio==19 & iva12==5   //Productos farmaceuticos IVA 5%
replace sectorio = 48 if sectorio==34 & iva12==10  //Gas y electricidad IVA 10%
replace sectorio = 49 if sectorio==40 & iva12==5   //Otros servicios IVA 5%
replace sectorio = 50 if sectorio==40 & iva12==10  //Otros servicios IVA 10%

*merge m:1 sectorio using "$data_pry\efectos_iva_2012.dta" 

merge m:1 sectorio using `efectos_iva_2012' 

drop if _merge==2   // eliminamos efectos para sectores no existentes en la base de gastos 
drop _merge

replace sectorio = 1  if sectorio==41 & iva12==5   //Agricultura IVA 5%
replace sectorio = 2  if sectorio==42 & iva12==10  //Caza IVA 10%
replace sectorio = 5  if sectorio==43 & iva12==5   //Carne IVA 5%
replace sectorio = 6  if sectorio==44 & iva12==5   //Molineria IVA 5%
replace sectorio = 8  if sectorio==45 & iva12==5   //Otros alimentos IVA 5%
replace sectorio = 15 if sectorio==46 & iva12==10  //Pulpa IVA 10%
replace sectorio = 19 if sectorio==47 & iva12==5   //Productos farmaceuticos IVA 5%
replace sectorio = 34 if sectorio==48 & iva12==10  //Gas y electricidad IVA 10%
replace sectorio = 40 if sectorio==49 & iva12==5   //Otros servicios IVA 5%
replace sectorio = 40 if sectorio==50 & iva12==10  //Otros servicios IVA 10%

tab sectorio

//SECTORES CREADOS PARA CAPTURAR DIFERENTES TASAS DE ISC

replace sectorio = 41 if sectorio==9 & isc12<=5 & isc12!=0
replace sectorio = 42 if sectorio==9 & isc12>=5 & isc12!=0
replace sectorio = 43 if sectorio==16 & isc12==24 
replace sectorio = 44 if sectorio==16 & isc12==34 
replace sectorio = 45 if sectorio==16 & isc12==38 
replace sectorio = 46 if sectorio==16 & isc12==18 
replace sectorio = 47 if sectorio==19 & isc12==0
replace sectorio = 48 if sectorio==34 & isc12==0

*merge m:1 sectorio using "$data_pry\efectos_isc_2012.dta"

merge m:1 sectorio using `efectos_isc_2012'


drop if _merge==2   // eliminamos efectos para sectores no existentes en la base de gastos 
drop _merge

replace sectorio = 9  if sectorio==41 & isc12<=5 & isc12!=0
replace sectorio = 9  if sectorio==42 & isc12>=5 & isc12!=0
replace sectorio = 16 if sectorio==43 & isc12==24 
replace sectorio = 16 if sectorio==44 & isc12==34 
replace sectorio = 16 if sectorio==45 & isc12==38 
replace sectorio = 16 if sectorio==46 & isc12==18 
replace sectorio = 19 if sectorio==47 & isc12==0
replace sectorio = 34 if sectorio==48 & isc12==0

/*=======================================================
            Calculo de Gasto Neto por Escenario                                            
=========================================================*/

//ESCENARIO 1: asume informalidad cero. Todos los bienes son comprados en lugares formales. 

gen      monto_iva_1  = gasto_compra*(iva12/100) + gasto_compra*indirect_iva11*(-1) if iva12>0  //bienes gravados, 1ra y 2da ronda
replace  monto_iva_1  = gasto_compra*indirect_iva10*(-1)  if iva12==0 //bienes exentos 

gen      gasto_antes_iva1 = gasto_compra - monto_iva_1

gen      monto_isc_1 =  gasto_antes_iva1*(isc12/100) + gasto_antes_iva1*indirect_isc11*(-1) if isc12>0 //bienes gravados, 1ra y 2da ronda
replace  monto_isc_1 =  gasto_antes_iva1*indirect_isc10*(-1) if isc12==0 //bienes exentos

gen      gasto_compra_neto1 = gasto_antes_iva1 - monto_isc_1   //gasto neto escenario 1 
 
//ESCENARIO 2: existe informalidad. Escenario LOWER BOUND donde la tasa efectiva de bienes gravados informales es cero

gen      monto_iva_2 = gasto_compra*(iva12/100) + gasto_compra*indirect_iva11*(-1) if iva12>0 & formal2==1  //bienes gravados formales, 1ra y 2da ronda
replace  monto_iva_2 = gasto_compra*indirect_iva10*(-1) if iva12==0   //bienes exentos formales e informales
replace  monto_iva_2 = gasto_compra*0 if iva12>0 & formal2==0         //bienes gravados informales

gen      gasto_antes_iva2 = gasto_compra - monto_iva_2 

gen      monto_isc_2 = gasto_antes_iva1*(isc12/100) + gasto_antes_iva1*indirect_isc11*(-1) if isc12>0 & formal2==1 //bienes gravados formales, 1ra y 2da ronda
replace  monto_isc_2 = gasto_antes_iva1*indirect_isc10*(-1) if isc12==0     //bienes exentos formales e informales
replace  monto_isc_2 = gasto_antes_iva1*0 if isc12>0 & formal2==0           //bienes gravados informales

gen      gasto_compra_neto2 = gasto_antes_iva2 - monto_isc_2  //gasto neto escenario 2 

//ESCENARIO 3: existe informalidad. Escenario UPPER BOUND donde bienes informales pagan impuesto escondido

gen      monto_iva_3 = gasto_compra*(iva12/100) + gasto_compra*indirect_iva11*(-1) if iva12>0 & formal2==1 //bienes gravados formales, 1ra y 2nda ronda
replace  monto_iva_3 = gasto_compra*indirect_iva10*(-1) if iva12==0 //bienes exentos formales e informales 
replace  monto_iva_3 = gasto_compra*indirect_iva10*(-1) + gasto_compra*indirect_iva11*(-1) if iva12>0 & formal2==0 //bienes gravados informales, 1ra y 2da ronda

gen      gasto_antes_iva3 = gasto_compra - monto_iva_3 

gen      monto_isc_3 = gasto_antes_iva3*(isc12/100) + gasto_antes_iva3*indirect_isc11*(-1) if isc12>0 & formal2==1 //bienes gravados formales, 1ra y 2da ronda
replace  monto_isc_3 = gasto_antes_iva3*indirect_isc10*(-1) if isc12==0 //bienes exentos formales e informales 
replace  monto_isc_3 = gasto_antes_iva3*indirect_isc10*(-1) + gasto_compra*indirect_isc11*(-1) if isc12>0 & formal2==0 //bienes gravados informales, 2nda ronda

gen      gasto_compra_neto3 = gasto_antes_iva3 - monto_isc_3

//solo efectos directos
gen check1     = gasto_compra*(isc12/100) if isc12>0 
replace check1 = 0 if isc12==0

gen check2     = gasto_compra*(isc12/100) if isc12>0 & formal2==1
replace check2 = gasto_compra*0 if isc12==0 | formal2==0

//datos para macrovalidacion
	gen monto_isc_s1_1 = monto_isc_1 if isc_cat==1
	gen monto_isc_s2_1 = monto_isc_1 if isc_cat==2
	gen monto_isc_s3_1 = monto_isc_1 if ga01c==502201006 | ga01c==401107002
	gen monto_isc_s4_1 = monto_isc_1 if isc_cat==4
	gen monto_isc_s5_1 = monto_isc_1 if isc_cat==5
	gen monto_isc_sE_1 = monto_isc_1 if isc_cat==. 

	gen monto_isc_s1_2 = monto_isc_2 if isc_cat==1
	gen monto_isc_s2_2 = monto_isc_2 if isc_cat==2
	gen monto_isc_s3_2 = monto_isc_2 if ga01c==502201006 | ga01c==401107002
	gen monto_isc_s4_2 = monto_isc_2 if isc_cat==4
	gen monto_isc_s5_2 = monto_isc_2 if isc_cat==5
	gen monto_isc_sE_2 = monto_isc_2 if isc_cat==. 

	gen monto_isc_s1_3 = monto_isc_3 if isc_cat==1
	gen monto_isc_s2_3 = monto_isc_3 if isc_cat==2
	gen monto_isc_s3_3 = monto_isc_3 if ga01c==502201006 | ga01c==401107002
	gen monto_isc_s4_3 = monto_isc_3 if isc_cat==4
	gen monto_isc_s5_3 = monto_isc_3 if isc_cat==5
	gen monto_isc_sE_3 = monto_isc_3 if isc_cat==. 

	foreach x in monto_isc_s1_1 monto_isc_s2_1 monto_isc_s3_1 monto_isc_s4_1 monto_isc_s5_1 monto_isc_sE_1 ///
				 monto_isc_s1_2 monto_isc_s2_2 monto_isc_s3_2 monto_isc_s4_2 monto_isc_s5_2 monto_isc_sE_2 ///
				 monto_isc_s1_3 monto_isc_s2_3 monto_isc_s3_3 monto_isc_s4_3 monto_isc_s5_3 monto_isc_sE_3 {		
				 replace `x' = 0 if `x'==.
				 }

preserve
groupfunction, sum(gasto* monto*) mean (fex decil quintil ipcm total_miembros check*) by(famunit) 
gen ingreso_hh12 = ipcm * total_miembros 

sum monto_iva* monto_isc_* gasto_compra_neto* ingreso_hh12 [w=fex]

*save "$data_pry\IT_base_gasto_neto_precios2012.dta", replace

tempfile  IT_base_gasto_neto_precios2012
save `IT_base_gasto_neto_precios2012'


restore

/* Pasamos impuestos pagados y gasto neto bajo los 3 escenarios a valores de 2016 */
	gen ingreso_hh = ipcm * total_miembros

	gen ingreso_hh12 = ingreso_hh

	foreach x of varlist monto_iva* monto_isc* gasto_compra_neto* ingreso_hh {
		replace `x' = `x'*(1 + `pc_growth'*`pthrough')
		}

	rename ingreso_hh ingreso_hh16

	label var ingreso_hh12 "Ingreso del hogar a precios 2012"
	label var ingreso_hh16 "Ingreso del hogar a precios 2016"

	label var monto_iva_1 "IVA pagado en 2012 - escenario 1"
	label var monto_iva_2 "IVA pagado en 2012 - escenario 2"
	label var monto_iva_3 "IVA pagado en 2012 - escenario 3"

	label var monto_isc_1 "ISC pagado en 2012 - escenario 1"
	label var monto_isc_2 "ISC pagado en 2012 - escenario 2"
	label var monto_isc_3 "ISC pagado en 2012 - escenario 3"

	label var gasto_compra_neto1 "Gasto Neto escenario 1"
	label var gasto_compra_neto2 "Gasto Neto escenario 2"
	label var gasto_compra_neto3 "Gasto Neto escenario 3"

*save "$data_pry\IT_base_gasto_neto_item.dta", replace 
tempfile IT_base_gasto_neto_item
save `IT_base_gasto_neto_item'

//save "C:\Users\lylig\Documents\Consultorias\2019\World Bank\Impuestos indirectos\Gasto_reforma\IT_base_gasto_neto_item.dta", replace 

groupfunction, sum(gasto* monto*) mean (fex decil quintil ipcm total_miembros) by(famunit) 

sum monto_iva* monto_isc_1 monto_isc_2 monto_isc_3  gasto_compra_neto*  [w=fex]

*save "$data_pry\IT_base_gasto_neto.dta", replace 

tempfile IT_base_gasto_neto
save `IT_base_gasto_neto'




