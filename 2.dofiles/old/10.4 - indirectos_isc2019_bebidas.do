
* PYSim2016
* Programa de Calculo de Efectos Indirectos via Matriz Insumo Producto
* Version: Noviembre 2019
* Autora: Lyliana Gayoso de Ervin
* TTL: Maria Gabriela Farfan Beltran
* Este do-file estima los efectos indirectos de reduccion de las tasas vigentes de ISC 2019 en el sector bebidas 
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
local nafta85       0.1440
local nafta88_96    0.2468
local nafta97       0.0013
local diesel        0.5708
local otros_comb    0.0371

// 1) Generamos los sectores adicionales en la primera columna 

local isc_sec "Beb_NA Beb_A Naft85 Nafta88_96 Nafta97 Diesel ProdFarm0 Gas_lic"

local nsec "1 2 3 4 5 6 7 8"

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
local num_5  45
local num_6  46
local num_7  47
local num_8  48

//Luego generamos las columnas que corresponden a los nuevos sectores
gen sector41 = sector9*0.03   //bebidas sin alcohol consumidas fuera del hogar 
gen sector42 = sector9*0.51   //bebidas alcoholicas 
gen sector43 = sector16*`nafta85'
gen sector44 = sector16*`nafta88_96'
gen sector45 = sector16*`nafta97'
gen sector46 = sector16*`diesel'
replace sector16 = sector16*`otros_comb'
gen sector47 = sector19*0.5  //productos farmaceuticos 5%
gen sector48 = sector34*0.5  //gas licuado

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
levelsof rank if sector=="Coque, petróleo refinado y combustible nuclear", local(where2)
levelsof rank if sector=="Productos farmacéuticos", local(where3)
levelsof rank if sector=="Electricidad y gas", local(where4)

drop rank

di `where1'
di `where2'
di `where3'
di `where4'

di `mylist'
foreach x of local mylist{
di `"`x'"'
}

foreach x of local mylist {
	if    !regexm(upper("`x'"), "sector9")  &!regexm(upper("`x'"), "sector16") &!regexm(upper("`x'"), "sector19") &!regexm(upper("`x'"), "sector34") ///
	     &!regexm(upper("`x'"), "sector41") &!regexm(upper("`x'"), "sector42") &!regexm(upper("`x'"), "sector43") &!regexm(upper("`x'"), "sector44") ///
		 &!regexm(upper("`x'"), "sector45") &!regexm(upper("`x'"), "sector46") &!regexm(upper("`x'"), "sector47") &!regexm(upper("`x'"), "sector48") {
		qui: replace `x' = `x'[`where1'] *`share1'         in `num_1'  //Reemplazar en bebidas sin alcohol consumidas fuera del hogar 
		qui: replace `x' = `x'[`where1'] *`share2'         in `num_2'  //Reemplazar en bebidas alcoholicas
		qui: replace `x' = `x'*(1-`share1' - `share2')     in `where1' //Reemplazar en bebidas sin alcohol consumidas en el hogar
		qui: replace `x' = `x'[`where2'] *`nafta85'        in `num_3'  //nafta 85
		qui: replace `x' = `x'[`where2'] *`nafta88_96'     in `num_4'  //nafta de menos de 97 octanos
		qui: replace `x' = `x'[`where2'] *`nafta97'        in `num_5'  //nafta 97 octanos y mas
		qui: replace `x' = `x'[`where2'] *`diesel'         in `num_6'  //diesel
		qui: replace `x' = `x'[`where2'] *`otros_comb'     in `where2' //otros combustibles  
		qui: replace `x' = `x'[`where3'] *0.5              in `num_7 ' //productos farmaceuticos 5%
		qui: replace `x' = `x'[`where3'] *0.5              in `where3' //productos farmaceuticos exentos
		qui: replace `x' = `x'[`where4'] *0.5              in `num_8'  //gas licuado
		qui: replace `x' = `x'[`where4'] *0.5              in `where4' //electridad
	}
}

replace sector41    = 0 in `num_1' 
replace sector42    = 0 in `num_2'
replace sector43    = 0 in `num_3'
replace sector44    = 0 in `num_4'
replace sector45    = 0 in `num_5'
replace sector46    = 0 in `num_6'
replace sector47    = 0 in `num_7'
replace sector48    = 0 in `num_8'

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

**Identifica sectores con choque de precios
local nogo "41 42"

 foreach x of local nogo {
	replace fixed_isc = 1 in `x'
	}

**Definicion de choques en precios
//En este paso se utiliza la formula (1-1/(1+isc/100)) para obtener la tasa efectiva. 
//Asi, una tasa de 5% equivale a 0.04762
	
gen     dp_isc = 0
replace dp_isc = -0.04762  in  41    //tasa efectiva en bebidas no alcoholicas
replace dp_isc = -0.11504  in  42    //incremento en tasa efectiva en bebidas alcoholicas 

costpush `sectors', fixed(fixed_isc) priceshock(dp_isc) genptot(total_isc19B_10) genpind(indirect_isc19B_10) 

list total_isc19B_10 indirect_isc19B_10

gen sectorio = _n
rename sector sectorioe

save `isc_effects', replace 
restore

*******************************************
*             SEGUNDA VUELTA              *
*******************************************

local fixprice "1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 43 44 45 46 47 48"

gen fixed = 0
foreach sec in `fixprice' {
replace fixed = 1 in `sec'  
}


merge 1:1 _n using `isc_effects', nogen keepusing( total_isc19B_10 indirect_isc19B_10)
gen dp = 0
foreach sec in `fixprice' {
replace dp= total_isc19B_10 in `sec'  
}
drop   total_isc19B_10 indirect_isc19B_10


/*
gen dp = 0
replace dp = -.00003717  in 1
replace dp = -.00001279  in 2
replace dp = 0           in 3
replace dp = -.00003035  in 4
replace dp = -.00004425  in 5
replace dp = -.00003502  in 6
replace dp = -.0000197   in 7
replace dp = -.00003361  in 8
replace dp = -.00003431  in 9
replace dp = -.00003596  in 10
replace dp = -.00002151  in 11
replace dp = -.00001943  in 12
replace dp = -.00004048  in 13
replace dp = -.00004182  in 14
replace dp = -.00003822  in 15
replace dp =  0          in 16
replace dp = -.00003775  in 17
replace dp = -.00003792  in 18
replace dp = -.00003739  in 19
replace dp = -.00003787  in 20
replace dp = -.00003062  in 21
replace dp = -.00002799  in 22
replace dp = -.00002799  in 23
replace dp = -.00003965  in 24
replace dp = -.00003873  in 25
replace dp =   0         in 26
replace dp = -.00003874  in 27
replace dp = -.00003875  in 28
replace dp = -.00003874  in 29
replace dp = -.00003834  in 30
replace dp =   0         in 31
replace dp = -.00003841  in 32
replace dp = -.00003484  in 33
replace dp = -.00000747  in 34
replace dp = -.00002495  in 35
replace dp = -.00019833  in 36
replace dp = -.00002658  in 37
replace dp = -.00002322  in 38
replace dp = -.00019816  in 39
replace dp = -.0001545   in 40
replace dp =   0         in 43
replace dp =   0         in 44
replace dp =   0         in 45
replace dp =   0         in 46
replace dp = -.00001834  in 47
replace dp = -.00000365  in 48
*/

costpush `sectors', fixed(fixed) priceshock(dp) genptot(total_isc19B_11) genpind(indirect_isc19B_11) 

list total_isc19B_11 indirect_isc19B_11

gen sectorio=_n
rename sector sectorioe

merge 1:1 sectorio sectorioe  using `isc_effects', nogen

keep  sectorio sectorioe total_isc19B_10 indirect_isc19B_10 total_isc19B_11 indirect_isc19B_11

order sectorio sectorioe total_isc19B_10 indirect_isc19B_10 total_isc19B_11 indirect_isc19B_11

tempfile efectos_isc_bebidas_2019
save  `efectos_isc_bebidas_2019'
 
*save "$data_pry\efectos_isc_bebidas_2019.dta", replace

