
* PYSim2016
* Programa de Calculo de Efectos Indirectos via Matriz Insumo Producto
* Version: Noviembre 2019
* Autora: Lyliana Gayoso de Ervin
* TTL: Maria Gabriela Farfan Beltran
* Este do-file estima los efectos indirectos de incrementos en las tasas vigentes de ISC en el 
* proyecto de modernizacion fiscal 
*===================================================================================================================
clear
set more off


*-----------------------------------------------------------------------------------------------------                    
* Paso 1. Lectura de la Matriz Insumo-Producto
*-----------------------------------------------------------------------------------------------------

import excel using "$data_pry/IT_MIP_Paraguay.xlsx", sheet("Aij") firstrow cellrange(A01:AO41)     

*-------------------------------------------------------------------------------------------------------                    
* Paso 2. Generacion de sectores adicionales para aislar distintas tasas de ISC               
*------------------------------------------------------------------------------------------------------- 

local share1        0.0300   //bebidas no alcoholicas consumidas fuera del hogar 
local share2        0.5100   //bebidas alcoholicas 

// 1) Generamos los sectores adicionales en la primera columna 

local isc_sec "Beb_NA Beb_A ProdFarm0 Gas_lic"

local nsec "1 2 3"

foreach x of local isc_sec 	{
	insobs 1, after(_N)
	count
		foreach v of local nsec	{
		local num_`v' = r(N)
		replace sector = "`x'" in `num_`v''
		}
	}

local num_1  41
local num_2  42
local num_3  43
local num_4  44 

//Luego generamos las columnas que corresponden a los nuevos sectores
gen sector41 = sector9*0.03   //bebidas sin alcohol consumidas fuera del hogar 
gen sector42 = sector9*0.51   //bebidas alcoholicas 
gen sector43 = sector19*0.5   //productos farmaceuticos exentos
gen sector44 = sector34*0.5   //gas licuado

//Trabajamos con las nuevas filas creadas
local mylist
foreach x of varlist *{
	cap confirm numeric variable `x'
	if _rc==0 local mylist `mylist' `x'
}

di `mylist'

gen rank=_n

//capturamos los sectores a ser subdivididos
levelsof rank if sector=="Bebidas", local(where1)
levelsof rank if sector=="Productos farmacéuticos", local(where2)
levelsof rank if sector=="Electricidad y gas", local(where3)

drop rank

di `where1'
di `where2'
di `where3'

di `mylist'
foreach x of local mylist{
di `"`x'"'
}

foreach x of local mylist {
	if    !regexm(upper("`x'"), "sector9")  &!regexm(upper("`x'"), "sector19") &!regexm(upper("`x'"), "sector34") &!regexm(upper("`x'"), "sector41") ///
	     &!regexm(upper("`x'"), "sector42") &!regexm(upper("`x'"), "sector43") & !regexm(upper("`x'"), "sector44") {
		qui: replace `x' = `x'[`where1'] *`share1'         in `num_1'  //Reemplazar en bebidas sin alcohol consumidas fuera del hogar 
		qui: replace `x' = `x'[`where1'] *`share2'         in `num_2'  //Reemplazar en bebidas alcoholicas
		qui: replace `x' = `x'*(1-`share1' - `share2')     in `where1' //Reemplazar en bebidas sin alcohol consumidas en el hogar
		qui: replace `x' = `x'[`where2'] *0.50             in `num_3'  //productos farmaceuticos exentos
		qui: replace `x' = `x'[`where2'] *0.50             in `where2' //productos farmaceuticos 5%
		qui: replace `x' = `x'[`where3'] *0.50             in `num_4'  //gas licuado
		qui: replace `x' = `x'[`where3'] *0.50             in `where3' //electricidad
		
	}
}

replace sector41    = 0 in `num_1' 
replace sector42    = 0 in `num_2'
replace sector43    = 0 in `num_3'
replace sector44    = 0 in `num_4'

*-------------------------------------------------------------------------------------------------------                    
* Paso 3. Introduccion de cambios en precios                
*------------------------------------------------------------------------------------------------------- 

*******************************************
*            PRIMERA VUELTA               *
*******************************************
local sectors
foreach var of varlist * {             
  if "`var'"~="sector" {              
	local sectors "`sectors' `var'"                         
  }                                    
}        

preserve
tempfile isc_effects

**Define matriz 
gen fixed_isc = 0                                                   

**Identifica sectores no exentos (con choques de precios)
local nogo "10 16 19 24 26 27 28 41 42 44"

 foreach x of local nogo {
	replace fixed_isc = 1 in `x'
	}

gen dp_isc = 0
replace dp_isc = 0.21260 in  10     //tasa cigarrillos 
replace dp_isc = 0.33333 in  16     //tasa efectiva maxima p/ combustibles  
replace dp_isc = 0.05660 in  19     //tasa productos farmaceuticos
replace dp_isc = 0.04762 in  24     //tasa productos fabricados de metal
replace dp_isc = 0.00990 in  26     //tasa equipos de oficina
replace dp_isc = 0.00990 in  27     //tasa maquinarias
replace dp_isc = 0.00990 in  28     //tasa radio
replace dp_isc = 0.04762 in  41     //tasa bebidas no alcoholicas
replace dp_isc = 0.11504 in  42     //tasa mas alta en bebidas alcoholicas
replace dp_isc = 0.33333 in  44     //tasa efectiva maxima gas licuado 

costpush `sectors', fixed(fixed_isc) priceshock(dp_isc) genptot(total_iscRE_10) genpind(indirect_iscRE_10) 

list total_iscRE_10 indirect_iscRE_10

gen sectorio = _n
rename sector sectorioe

save `isc_effects', replace 
restore

*******************************************
*             SEGUNDA VUELTA              *
*******************************************

local fixprice "1 2 3 4 5 6 7 8 9 11 12 13 14 15 17 18 20 21 22 23 25 29 30 31 32 33 34 35 36 37 38 39 40 43"

gen fixed = 0
foreach sec in `fixprice' {
replace fixed = 1 in `sec'  
}



merge 1:1 _n using `isc_effects', nogen keepusing( total_iscRE_10 indirect_iscRE_10)
gen dp = 0
foreach sec in `fixprice' {
replace dp= total_iscRE_10 in `sec'  
}
drop   total_iscRE_10 indirect_iscRE_10

/*
gen dp = 0
replace dp = 0.01529019 in 1
replace dp = 0.0167125  in 2
replace dp = 0          in 3
replace dp = 0.07005696 in 4
replace dp = 0.0143086  in 5
replace dp = 0.01639602 in 6
replace dp = 0.01260232 in 7
replace dp = 0.01443572 in 8
replace dp = 0.02148118 in 9
replace dp = 0.01579303 in 11
replace dp = 0.01569756 in 12
replace dp = 0.01323266 in 13
replace dp = 0.01810411 in 14
replace dp = 0.01756995 in 15
replace dp = 0.01742145 in 17
replace dp = 0.01683402 in 18
replace dp = 0.0170014  in 20
replace dp = 0.05694093 in 21
replace dp = 0.01260575 in 22
replace dp = 0.01260572 in 23
replace dp = 0.02463386 in 25
replace dp = 0.0313026  in 29
replace dp = 0.02667486 in 30
replace dp = 0          in 31
replace dp = 0.02677113 in 32
replace dp = 0.0169282  in 33
replace dp = 0.01873097 in 34
replace dp = 0.01731077 in 35
replace dp = 0.0672645  in 36
replace dp = 0.00818275 in 37
replace dp = 0.00515843 in 38
replace dp = 0.02131702 in 39
replace dp = 0.02140755 in 40
replace dp = 0.00830661 in 43
*/

costpush `sectors', fixed(fixed) priceshock(dp) genptot(total_iscRE_11) genpind(indirect_iscRE_11) 

list total_iscRE_11 indirect_iscRE_11

gen sectorio=_n
rename sector sectorioe

merge 1:1 sectorio sectorioe  using `isc_effects', nogen

keep  sectorio sectorioe total_iscRE_10 indirect_iscRE_10 total_iscRE_11 indirect_iscRE_11

order sectorio sectorioe total_iscRE_10 indirect_iscRE_10 total_iscRE_11 indirect_iscRE_11

tempfile efectos_isc_reforma
save    `efectos_isc_reforma'
 
*save "$data_pry\efectos_isc_reforma.dta", replace

