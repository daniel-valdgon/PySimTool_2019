
* PYSim2016
* Programa de Calculo de Efectos Indirectos via Matriz Insumo Producto
* Version: Noviembre 2019
* Autora: Lyliana Gayoso de Ervin
* TTL: Maria Gabriela Farfan Beltran
* Este do-file estima los efectos indirectos de reduccion de las tasas ISC en el sector combustibles 
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
gen sector47 = sector19*0.5   //productos farmaceuticos exentos
gen sector48 = sector34*0.5   //gas licuado

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

**Identifica sectores no exentos (sin choques)
local nogo "16 43 44 45 46 48"

 foreach x of local nogo {
	replace fixed_isc = 1 in `x'
	}
	

	
	
gen     dp_isc =  0 
replace dp_isc = -0.1667  in  16   //tasa efectiva en otros combustibles (20%)
replace dp_isc = -0.19355 in  43   //tasa efectiva nafta 85
replace dp_isc = -0.25373 in  44   //tasa efectiva nafta hasta 96.9 octanos
replace dp_isc = -0.27536 in  45   //tasa efectiva nafta 97 octanos y mas
replace dp_isc = -0.15254 in  46   //tasa efectiva  diesel
replace dp_isc = -0.09091 in  48   //incremento en tasa efectiva en gas licuado

costpush `sectors', fixed(fixed_isc) priceshock(dp_isc) genptot(total_isc19C_10) genpind(indirect_isc19C_10) 

list total_isc19C_10 indirect_isc19C_10

gen sectorio = _n
rename sector sectorioe

save `isc_effects', replace 
restore

*******************************************
*             SEGUNDA VUELTA              *
*******************************************

local fixprice "1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 47"

gen fixed = 0
foreach sec in `fixprice' {
replace fixed = 1 in `sec'  
}

merge 1:1 _n using `isc_effects', nogen keepusing( total_isc19C_10 indirect_isc19C_10)
gen dp = 0
foreach sec in `fixprice' {
replace dp= total_isc19C_10 in `sec'  
}
drop   total_isc19C_10 indirect_isc19C_10

/*

gen dp = 0
replace dp = -.00767097 in 1
replace dp = -.00874372 in 2
replace dp = 0          in 3
replace dp = -.03695387 in 4
replace dp = -.00668304 in 5
replace dp = -.00727647 in 6
replace dp = -.00490133 in 7
replace dp = -.00629214 in 8
replace dp = -.00779263 in 9
replace dp = -.00632423 in 10
replace dp = -.00661073 in 11
replace dp = -.00652898 in 12 
replace dp = -.00622898 in 13
replace dp = -.00861846 in 14
replace dp = -.00817832 in 15
replace dp = -.00699253 in 17
replace dp = -.0069511  in 18
replace dp = -.0066062  in 19
replace dp = -.00718401 in 20
replace dp = -.02950953 in 21
replace dp = -.00590558 in 22
replace dp = -.00590556 in 23
replace dp = -.01156017 in 24
replace dp = -.01101069 in 25
replace dp = 0          in 26
replace dp = -.01469507 in 27
replace dp = -.01474114 in 28
replace dp = -.01469507 in 29
replace dp = -.01066467 in 30
replace dp = 0          in 31
replace dp = -.01069483 in 32
replace dp = -.00777506 in 33
replace dp = -.00558269 in 34
replace dp = -.00867307 in 35
replace dp = -.03606963 in 36
replace dp = -.00370599 in 37
replace dp = -.00213487 in 38
replace dp = -.00942465 in 39
replace dp = -.00981335 in 40
replace dp = -.00023378 in 41
replace dp = -.00397424 in 42 
replace dp = -.00324055 in 47

*/



costpush `sectors', fixed(fixed) priceshock(dp) genptot(total_isc19C_11) genpind(indirect_isc19C_11) 

list total_isc19C_11 indirect_isc19C_11

gen sectorio=_n
rename sector sectorioe

merge 1:1 sectorio sectorioe  using `isc_effects', nogen

keep  sectorio sectorioe total_isc19C_10 indirect_isc19C_10 total_isc19C_11 indirect_isc19C_11

order sectorio sectorioe total_isc19C_10 indirect_isc19C_10 total_isc19C_11 indirect_isc19C_11

tempfile efectos_isc_combustibles_2019
save `efectos_isc_combustibles_2019'
 
*save "$data_pry\efectos_isc_combustibles_2019.dta", replace


