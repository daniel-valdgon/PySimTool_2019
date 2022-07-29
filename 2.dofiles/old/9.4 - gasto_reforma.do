* PYSim2016
* Programa de Calculo de Base de Datos para Simulaciones de Impuestos Indirectos
* Version: Noviembre 2019
* Autora: Lyliana Gayoso de Ervin
* TTL: Maria Gabriela Farfan Beltran
* Este do-file calcula montos de impuestos pagados a tasas vigentes de 2019 y de reforma fiscal
*===================================================================================================================
clear
set more off


/*=======================================================
             Unir base gasto c/ efectos indirectos                                            
=========================================================*/

*use "$data_pry\IT_base_gasto_neto_item.dta",clear

use `IT_base_gasto_neto_item' ,clear


drop total_iva10 indirect_iva10 total_iva11 indirect_iva11 total_isc10 indirect_isc10 total_isc11 indirect_isc11

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

*merge m:1 sectorio using "$data_pry\efectos_iva_2019.dta" 

merge m:1 sectorio using `efectos_iva_2019' 

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

//SECTORES CREADOS PARA CAPTURAR DIFERENTES TASAS DE ISC - 2019 
//Naft85 Nafta88_96 Nafta97 Diesel

replace sectorio = 41 if sectorio==9  & isc19<=5  & isc19!=0
replace sectorio = 42 if sectorio==9  & isc19>5   & isc19!=0
replace sectorio = 43 if sectorio==16 & isc19==24 
replace sectorio = 44 if sectorio==16 & isc19==34 
replace sectorio = 45 if sectorio==16 & isc19==38 
replace sectorio = 46 if sectorio==16 & isc19==18 
replace sectorio = 47 if sectorio==19 & isc19==0
replace sectorio = 48 if sectorio==34 & isc19==0

*merge m:1 sectorio using "$data_pry\efectos_isc_2019.dta"

merge m:1 sectorio using `efectos_isc_2019' 

drop if _merge==2   // eliminamos efectos para sectores no existentes en la base de gastos 
drop _merge

replace sectorio = 9 if sectorio==41  & isc19<=5  & isc19!=0
replace sectorio = 9 if sectorio==42  & isc19>5   & isc19!=0
replace sectorio = 16 if sectorio==43 & isc19==24 
replace sectorio = 16 if sectorio==44 & isc19==34 
replace sectorio = 16 if sectorio==45 & isc19==38 
replace sectorio = 16 if sectorio==46 & isc19==18
replace sectorio = 19 if sectorio==47 & isc19==0
replace sectorio = 34 if sectorio==48 & isc19==0

//SECTORES CREADOS PARA CAPTURAR DIFERENTES TASAS DE ISC - REFORMA
replace sectorio = 41 if sectorio==9  & isc_max<=6  & isc_max!=0
replace sectorio = 42 if sectorio==9  & isc_max>6   & isc_max!=0
replace sectorio = 43 if sectorio==19 & isc_max==0
replace sectorio = 44 if sectorio==34 & isc_max==0

*merge m:1 sectorio using "$data_pry\efectos_isc_reforma.dta"
merge m:1  sectorio using `efectos_isc_reforma'

drop if _merge==2   // eliminamos efectos para sectores no existentes en la base de gastos 
drop _merge

replace sectorio = 9 if sectorio==41  & isc_max<=6  & isc_max!=0
replace sectorio = 9 if sectorio==42  & isc_max>6   & isc_max!=0
replace sectorio = 19 if sectorio==43 & isc_max==0 
replace sectorio = 34 if sectorio==44 & isc_max==0

/*===========================================================
    Calculo de Gasto a Tasas 2019 y Reforma por Escenario                                            
=============================================================*/

*-------------------------------------------------------------------------------------------*
* ESCENARIO 1: asume informalidad cero. Todos los bienes son comprados en lugares formales. 
*-------------------------------------------------------------------------------------------*

/*  Gasto y monto de impuesto pagado a tasas vigentes 2019 */
gen      monto_isc19_1     =  gasto_compra_neto1*(isc19/100 + indirect_isc19_11) if isc19>0 //bienes gravados
replace  monto_isc19_1     =  gasto_compra_neto1*indirect_isc19_10 if isc19==0 //bienes exentos
gen      gasto_con_isc19_1 =  gasto_compra_neto1 + monto_isc19_1

gen      monto_iva19_1     = gasto_con_isc19_1*(iva19/100 + indirect_iva19_11) if iva19>0 //bienes gravados 
replace  monto_iva19_1     = gasto_con_isc19_1*indirect_iva19_10 if iva19==0 //bienes exentos 
gen      gasto_con_iva19_1 = gasto_con_isc19_1 + monto_iva_1

gen      gasto_compra19_1  = gasto_con_iva19_1 //gasto compra a tasas 2019 escenario 1 

/*  Gasto y monto de impuesto pagado a tasas REFORMA */
//como no hubo cambios en la tasa de IVA, los choques se realizaron solo para tasas de ISC.
//utilizamos tasas vigentes al 2019 solo para IVA.
 
gen      monto_iscRE_1     =  gasto_compra_neto1*(isc_max/100 + indirect_iscRE_11) if isc_max>0 //bienes gravados
replace  monto_iscRE_1     =  gasto_compra_neto1*indirect_iscRE_10 if isc_max==0 //bienes exentos
gen      gasto_con_iscRE_1 =  gasto_compra_neto1 + monto_iscRE_1

gen      monto_ivaRE_1     =  gasto_con_iscRE_1*(iva19/100 + indirect_iva19_11) if iva19>0
replace  monto_ivaRE_1     =  gasto_con_iscRE_1*indirect_iva19_10 if iva19==0 //bienes exentos
gen      gasto_con_ivaRE_1 =  gasto_con_iscRE_1 + monto_ivaRE_1  

gen      gasto_compraRE_1  =  gasto_con_ivaRE_1 //gasto neto tasas REFORMA escenario 1 

*-------------------------------------------------------------------------------------------*
* ESCENARIO 2: existe informalidad. Escenario LOWER BOUND donde la tasa efectiva de bienes
* gravados informales es cero.
*-------------------------------------------------------------------------------------------*

/*  Gasto y monto de impuesto pagado a tasas vigentes 2019 */
gen      monto_isc19_2     =  gasto_compra_neto2*(isc19/100 + indirect_isc19_11) if isc19>0 & formal2==1 //bienes gravados formales, 1ra y 2da ronda
replace  monto_isc19_2     =  gasto_compra_neto2*indirect_isc19_10 if isc19==0 //bienes exentos formales e informales
replace  monto_isc19_2     =  gasto_compra_neto2*0 if isc19>0 & formal2==0     //bienes gravados informales
gen      gasto_con_isc19_2 =  gasto_compra_neto2 + monto_isc19_2

gen      monto_iva19_2     = gasto_con_isc19_2*(iva19/100 + indirect_iva19_11) if iva19>0 & formal2==1 //bienes gravados formales, 1ra y 2da ronda
replace  monto_iva19_2     = gasto_con_isc19_2*indirect_iva19_10 if iva19==0   //bienes exentos formales e informales
replace  monto_iva19_2     = gasto_con_isc19_2*0 if iva19>0 & formal2==0       //bienes gravados informales
gen      gasto_con_iva19_2 = gasto_con_isc19_2 + monto_iva19_2

gen      gasto_compra19_2  = gasto_con_iva19_2 //gasto compra a tasas 2019 escenario 2

/*  Gasto y monto de impuesto pagado a tasas REFORMA */
gen      monto_iscRE_2     =  gasto_compra_neto2*(isc_max/100 + indirect_iscRE_11) if isc_max>0 & formal2==1 //bienes gravados formales, 1ra y 2da ronda
replace  monto_iscRE_2     =  gasto_compra_neto2*indirect_iscRE_10 if isc_max==0 //bienes exentos formales e informales
replace  monto_iscRE_2     =  gasto_compra_neto2*0 if isc_max>0 & formal2==0     //bienes gravados informales
gen      gasto_con_iscRE_2 =  gasto_compra_neto2 + monto_iscRE_2

gen      monto_ivaRE_2     = gasto_con_iscRE_2*(iva19/100 + indirect_iva19_11) if iva19>0 & formal2==1  //bienes gravados formales, 1ra y 2da ronda
replace  monto_ivaRE_2     = gasto_con_iscRE_2*indirect_iva19_10 if iva19==0   //bienes exentos formales e informales
replace  monto_ivaRE_2     = gasto_con_iscRE_2*0 if iva19>0 & formal2==0       //bienes gravados informales
gen      gasto_con_ivaRE_2 = gasto_con_iscRE_2 + monto_ivaRE_2

gen      gasto_compraRE_2  = gasto_con_ivaRE_2 //gasto compra a tasas REFORMA escenario 2

*-------------------------------------------------------------------------------------------*
*   ESCENARIO 3: existe informalidad. Escenario UPPER BOUND donde bienes informales 
*   pagan impuesto escondido
*-------------------------------------------------------------------------------------------*
/*  Gasto y monto de impuesto pagado a tasas vigentes 2019 */

gen      monto_isc19_3     = gasto_compra_neto3*(isc19/100 + indirect_isc19_11) if isc19>0 & formal2==1 //bienes gravados formales, 1ra y 2da ronda
replace  monto_isc19_3     = gasto_compra_neto3*indirect_isc19_10 if isc19==0 //bienes exentos formales e informales 
replace  monto_isc19_3     = gasto_compra_neto3*(indirect_isc19_10 + indirect_isc19_11) if isc19>0 & formal2==0 //bienes gravados informales, 1ra y 2da ronda
gen      gasto_con_isc19_3 = gasto_compra_neto3 + monto_isc19_3

gen      monto_iva19_3     = gasto_con_isc19_3*(iva19/100 + indirect_iva19_11) if iva19>0 & formal2==1 //bienes gravados formales, 1ra y 2da ronda
replace  monto_iva19_3     = gasto_con_isc19_3*indirect_iva19_10 if iva19==0 //bienes exentos formales e informales 
replace  monto_iva19_3     = gasto_con_isc19_3*(indirect_iva19_10 + indirect_iva19_11) if iva19>0 & formal2==0 //bienes gravados informales, 1ra y 2da ronda
gen      gasto_con_iva19_3 = gasto_con_isc19_3 + monto_iva19_3

gen      gasto_compra19_3  = gasto_con_iva19_3 //gasto compra a tasas 2019 escenario 3 

/*  Gasto y monto de impuesto pagado a tasas REFORMA */
gen      monto_iscRE_3     = gasto_compra_neto3*(isc_max/100 + indirect_iscRE_11)  if isc_max>0 & formal2==1 //bienes gravados formales, 1ra y 2da ronda
replace  monto_iscRE_3     = gasto_compra_neto3*indirect_iscRE_10 if isc_max==0 //bienes exentos formales e informales 
replace  monto_iscRE_3     = gasto_compra_neto3*(indirect_iscRE_10 + indirect_iscRE_11) if isc_max>0 & formal2==0 //bienes gravados informales, 1ra y 2da ronda
gen      gasto_con_iscRE_3 = gasto_compra_neto3 + monto_iscRE_3

gen      monto_ivaRE_3     = gasto_con_iscRE_3*(iva19/100 + indirect_iva19_11) if iva19>0 & formal2==1 //bienes gravados formales, 1ra y 2da ronda
replace  monto_ivaRE_3     = gasto_con_iscRE_3*indirect_iva19_10 if iva19==0 //bienes exentos formales e informales 
replace  monto_ivaRE_3     = gasto_con_iscRE_3*(indirect_iva19_10 + indirect_iva19_11) if iva19>0 & formal2==0 //bienes gravados informales, 1ra ronda
gen      gasto_con_ivaRE_3 = gasto_con_iscRE_3 + monto_ivaRE_3

gen      gasto_compraRE_3  = gasto_con_ivaRE_3 //gasto compra a tasas 2019 escenario 3

label var monto_iva19_1 "IVA pagado en 2019 - escenario 1"
label var monto_iva19_2 "IVA pagado en 2019 - escenario 2"
label var monto_iva19_3 "IVA pagado en 2019 - escenario 3"

label var monto_ivaRE_1 "IVA pagado Reforma - escenario 1"
label var monto_ivaRE_2 "IVA pagado Reforma - escenario 2"
label var monto_ivaRE_3 "IVA pagado Reforma - escenario 3"

label var monto_isc19_1 "ISC pagado en 2019 - escenario 1"
label var monto_isc19_2 "ISC pagado en 2019 - escenario 2"
label var monto_isc19_3 "ISC pagado en 2019 - escenario 3"

label var monto_iscRE_1 "ISC pagado Reforma - escenario 1"
label var monto_iscRE_2 "ISC pagado Reforma - escenario 2"
label var monto_iscRE_3 "ISC pagado Reforma - escenario 3"

label var gasto_compra19_1 "Gasto Compra 2019 - escenario 1"
label var gasto_compra19_2 "Gasto Compra 2019 - escenario 2"
label var gasto_compra19_3 "Gasto Compra 2019 - escenario 3"

label var gasto_compraRE_1 "Gasto Compra Reforma - escenario 1"
label var gasto_compraRE_2 "Gasto Compra Reforma - escenario 2"
label var gasto_compraRE_3 "Gasto Compra Reforma - escenario 3"

*save "$data_pry\IT_base_gastos_reforma_hogar.dta", replace
tempfile IT_base_gastos_reforma_hogar
save `IT_base_gastos_reforma_hogar'

groupfunction, sum(gasto* monto*) mean (fex ingreso_hh12 ingreso_hh16 total_miembros) by(famunit) 

*save "$data_pry\IT_base_gasto_escenarios.dta", replace 

tempfile IT_base_gasto_escenarios
save `IT_base_gasto_escenarios'


sum gasto_compra19* [w=fex]
sum gasto_compraRE* [w=fex]
sum monto_iva19* monto_isc19* [w=fex]
sum monto_ivaRE* monto_iscRE* [w=fex]
