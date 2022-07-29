
* PYSim2016
* Programa de Calculo de Efectos Indirectos via Matriz Insumo Producto
* Version: Noviembre 2019
* Autora: Lyliana Gayoso de Ervin
* TTL: Maria Gabriela Farfan Beltran
* Este do-file estima los efectos indirectos de las tasas vigentes de IVA en el 2019
*===================================================================================================================
*-----------------------------------------------------------------------------------------------------                    
* Paso 1. Lectura de la Matriz Insumo-Producto
*-----------------------------------------------------------------------------------------------------
clear
set more off

import excel using "$data_pry/IT_MIP_Paraguay.xlsx", sheet("Aij") firstrow cellrange(A01:AO41)     

/*            SUPUESTOS
Sectores c/ IVA 5 y 10: 50% cada uno
Sectores c/ IVA exento y otro : 50% cada uno
Sectores c/ 3 tasas de IVA: 33% cada uno  */   

*-------------------------------------------------------------------------------------------------------                    
* Paso 2. Generamos sectores adicionales para aislar IVA 5% e IVA 10%                
*------------------------------------------------------------------------------------------------------- 

// 1) Generamos los sectores adicionales en la primera columna 

local iva_sec "AgIVA5 CazaIVA5 CarneIVA5 MolIVA5 OtrIVA5 PulpIVA0 PfIVA5 GasIVA0 OsIVA0 OsIVA5"

local nsec "1 2 3 4 5 6 7 8 9 10"

foreach x of local iva_sec 	{
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
local num_9  49
local num_10 50


//Luego generamos las columnas que corresponden a los nuevos sectores
gen sector41 = sector1*0.50
gen sector42 = sector2*0.50
gen sector43 = sector5*0.50
gen sector44 = sector6*0.50
gen sector45 = sector8*0.50
gen sector46 = sector15*0.5
gen sector47 = sector19*0.5
gen sector48 = sector34*0.5
gen sector49 = sector40*0.33
gen sector50 = sector40*0.33

//Trabajamos con las nuevas filas creadas
local mylist
foreach x of varlist *{
	cap confirm numeric variable `x'
	if _rc==0 local mylist `mylist' `x'
}

di `mylist'

gen rank=_n

//capturamos los sectores a ser subdividos
levelsof rank if sector=="Agricultura y forestal", local(where1)
levelsof rank if sector=="Caza y pesca", local(where2)
levelsof rank if sector=="Carne y derivados", local(where3)
levelsof rank if sector=="Molinería, panadería y pastas", local(where4)
levelsof rank if sector=="Otros productos alimenticios", local(where5)
levelsof rank if sector=="Pulpa de madera, papel, imprentas y editoriales", local(where6)
levelsof rank if sector=="Productos farmacéuticos", local(where7)
levelsof rank if sector=="Electricidad y gas", local(where8)
levelsof rank if sector=="Otros servicios", local(where9)

drop rank

di `where1'
di `where9'

di `mylist'
foreach x of local mylist{
di `"`x'"'
}

//Aplicamos el share por cada nuevo sector generado 
local share50 0.50
local share33 0.33 

foreach x of local mylist {
		if !regexm(upper("`x'"), "sector1")  & !regexm(upper("`x'"), "sector2")  & !regexm(upper("`x'"), "sector5")  & !regexm(upper("`x'"), "sector6")  ///
		&  !regexm(upper("`x'"), "sector8")  & !regexm(upper("`x'"), "sector15") & !regexm(upper("`x'"), "sector19") & !regexm(upper("`x'"), "sector34") ///
		&  !regexm(upper("`x'"), "sector40") & !regexm(upper("`x'"), "sector41") & !regexm(upper("`x'"), "sector42") & !regexm(upper("`x'"), "sector43") ///
		&  !regexm(upper("`x'"), "sector44") & !regexm(upper("`x'"), "sector45") & !regexm(upper("`x'"), "sector46") & !regexm(upper("`x'"), "sector47") ///
		&  !regexm(upper("`x'"), "sector48") & !regexm(upper("`x'"), "sector49") & !regexm(upper("`x'"), "sector50") {
		qui: replace `x' = `x'[`where1']*`share50' in `num_1'   
		qui: replace `x' = `x'[`where2']*`share50' in `num_2' 
		qui: replace `x' = `x'[`where3']*`share50' in `num_3' 
		qui: replace `x' = `x'[`where4']*`share50' in `num_4' 
		qui: replace `x' = `x'[`where5']*`share50' in `num_5'
		qui: replace `x' = `x'[`where6']*`share50' in `num_6'  
		qui: replace `x' = `x'[`where7']*`share50' in `num_7' 
		qui: replace `x' = `x'[`where8']*`share50' in `num_8' 
		qui: replace `x' = `x'[`where9']*`share33' in `num_9' 
		qui: replace `x' = `x'[`where9']*`share33' in `num_10'  
		qui: replace `x' = `x'*(1 - `share50'  ) in `where1'
		qui: replace `x' = `x'*(1 - `share50'  ) in `where2'
		qui: replace `x' = `x'*(1 - `share50'  ) in `where3'
		qui: replace `x' = `x'*(1 - `share50'  ) in `where4'
		qui: replace `x' = `x'*(1 - `share50'  ) in `where5'
		qui: replace `x' = `x'*(1 - `share50'  ) in `where6'
		qui: replace `x' = `x'*(1 - `share50'  ) in `where7'
		qui: replace `x' = `x'*(1 - `share50'  ) in `where8'
		qui: replace `x' = `x'*(1 - `share33'- `share33') in `where9'
		}
}


replace sector41 = 0 in `num_1'  //Porque i,i `x' es ==0
replace sector42 = 0 in `num_2'
replace sector43 = 0 in `num_3'
replace sector44 = 0 in `num_4'
replace sector45 = 0 in `num_5'
replace sector46 = 0 in `num_6'
replace sector47 = 0 in `num_7'
replace sector48 = 0 in `num_8'
replace sector49 = 0 in `num_9'
replace sector50 = 0 in `num_10'

*-------------------------------------------------------------------------------------------------------                    
* Paso 3. Introduccion de cambios en precios                
*------------------------------------------------------------------------------------------------------- 

*******************************************
*            PRIMERA VUELTA               *
*******************************************

/*  Local Macro que captura nombres de los sectores de la MIP */
local sectors 
 foreach var of varlist * {            // captura las variables en un local     
	if "`var'"~="sector"    {        
			local sectors "`sectors' `var'"                         
	}                                    
  }
  
preserve
tempfile iva_effects

//sectores exentos                  16 46 48 49
//sectores sin productos en EIG     21 29 31 32

local fixprice "1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 17 18 19 20 22 23 24 25 26 27 28 30 33 34 35 36 37 38 39 40 41 42 43 44 45 47 50"                                                

gen fixed = 0
foreach sec in `fixprice' {
replace fixed = 1 in `sec'  //Sectors are fixed
}

//AgIVA5 CazaIVA5 CarneIVA5 MolIVA5 OtrIVA5 PulpIVA0 PfIVA5 GasIVA0 OsIVA0 OsIVA5
//41      42      43        44      45      46       47     48      49     50

local fixprice10 "1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 17 18 19 20 22 23 24 25 26 27 28 30 33 34 35 36 37 38 39 40"
local fixprice5  "41 42 43 44 45 47 50 "

gen dp = 0
foreach sec in `fixprice10' {
replace dp = 0.09090909 in `sec'  //Sectors are fixed
}

foreach sec in `fixprice5' {
replace dp = 0.04761905 in `sec'  //Sectors are fixed
}

costpush `sectors', fixed(fixed) price(dp) genptot(total_iva19_10) genpind(indirect_iva19_10) 
list total_iva19_10 indirect_iva19_10

gen sectorio = _n
rename sector sectorioe

save `iva_effects', replace 
restore

*******************************************
*             SEGUNDA VUELTA              *
*******************************************

local fixprice "16 21 29 31 32 46 48 49"

gen fixed = 0
foreach sec in `fixprice' {
replace fixed = 1 in `sec'  
}

merge 1:1 _n using `iva_effects', nogen keepusing( total_iva19_10 indirect_iva19_10)
gen dp = 0
foreach sec in `fixprice' {
replace dp= total_iva19_10 in `sec'  
}
drop   total_iva19_10 indirect_iva19_10


/*
gen dp = 0
replace dp = 0 in 16
replace dp = 0.03767722  in 21
replace dp = 0.04354895  in 29
replace dp = 0           in 31
replace dp = 0.03797918  in 32
replace dp = 0.01643302  in 46
replace dp = 0.0038632   in 48
replace dp = 0.00769271  in 49
*/

costpush `sectors', fixed(fixed) price(dp) genptot(total_iva19_11) genpind(indirect_iva19_11)
list total_iva19_11 indirect_iva19_11

gen sectorio=_n
rename sector sectorioe

merge 1:1 sectorio sectorioe  using `iva_effects', nogen

keep sectorio sectorioe total_iva19_10 indirect_iva19_10 total_iva19_11 indirect_iva19_11

order sectorio sectorioe total_iva19_10 indirect_iva19_10 total_iva19_11 indirect_iva19_11

* save "$data_pry\efectos_iva_2019.dta", replace

tempfile    efectos_iva_2019
save       `efectos_iva_2019'