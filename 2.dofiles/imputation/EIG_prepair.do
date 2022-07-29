
* prepair variable for imputation EIG

use "$indivdta_eig"   , clear


// jefe hogar 

gen jefe=  p02==1

// edad jefe

gen edad_jefe=edad    if  jefe==1 


// menor en el hogar

gen menor= edad<12

// sexo jefe

gen sexo= p05==1

gen sexo_jefe=sexo     if  jefe==1


// married jefe

gen married= p07==1

gen married_jefe= married  if  jefe==1


// años estudio

gen esco_jefe=  anioest  if jefe==1

replace esco_jefe=0  if esco_jefe==99


// ocupado

gen ocupado= b11!=.

gen ocupado_jefe= ocupado  if jefe==1


// asalariado 

gen asalariado= b11==1 | b11==2 

gen asalariado_jefe= asalariado   if jefe==1


// cuenta propia 


gen cpropia= b11==3 | b11==4 

gen cpropia_jefe= cpropia  if jefe==1

// migrò   (5 años atras)

gen migro= p10!=.

gen migr_jefe=  migro   if jefe==1


// hh size

bys anio upm nvivi nhoga: gen hhsize=_N


// income 


egen agro_income= rowtotal(d0101 d0102)     if    (b11 !=1 & b11!=2)  &  b01crec==6



collapse (max) fex hhsize migr_jefe cpropia_jefe asalariado_jefe ocupado_jefe esco_jefe married_jefe sexo_jefe edad_jefe  (sum) menores_hh=menor  agro_income_hh=agro_income  , by(anio upm nvivi nhoga)


tempfile hhvars

save `hhvars'


**********************************************************
*   Nivel de hogar
**********************************************************
use "$agg_eig"  , clear

_ebin ipcm  [aw=facpob], nq(10) gen(deciles)

egen agro_income=rowtotal(d01aimbe d01bimbe)

*br anio upm nvivi nhoga

keep  anio upm nvivi nhoga deciles  agro_income

tempfile hhdecs

save `hhdecs'



use "$hogdta_eig"   , clear


// tipo vivienda 

gen tipo_vivienda=0                              //otro
replace tipo_vivienda=1    if v01==1 | v01==2    //casa rancho
replace tipo_vivienda=2    if v01==3    // apartamento 

// numero piezas 

gen numero_piezas=  v02a

// techo

gen techo=0
replace  techo=1     if   v05==1    //teja
replace  techo=3     if   v05==3    //fibrocemento
replace  techo=4     if   v05==4    //chapa zinc
replace  techo=5     if   v05==6    //hormigon


// agua 

gen agua=0
replace agua=1   if v07==1      // Essap
replace agua=2   if v07==2      // SENASA
replace agua=3   if v07==7      //  Red comunitaria
replace agua=4   if v07==6      //  Privada
replace agua=5	 if v07==5       // Pozo con bomba 

// tenure 

gen v_propia= v17==1            // propia


// celular 

gen celular= v10b==1

// computadora

gen computadora= v11a ==1 

// rural

gen rural= area==6


// depto 

gen depto=  dptorep 

keep  upm nvivi nhoga  tipohoga tipo_vivienda numero_piezas techo agua v_propia celular computadora rural depto fex  


//merge jefe vars 

merge 1:1 upm nvivi nhoga using `hhvars'   , nogen

merge 1:1 upm nvivi nhoga using `hhdecs'   , nogen

gen UPM=upm
gen NVIVI=nvivi
gen NHOGA=nhoga

foreach var in upm nvivi nhoga {
	tostring `var', replace
	replace `var'=`var' + "X" if length(`var')==2
	replace `var'=`var' + "XX" if length(`var')==1
}

egen double famunit=concat(upm nvivi nhoga)

sort UPM NVIVI NHOGA

gen hhid=_n

tempfile  eig_toimpute

save `eig_toimpute'

save "$data_pry\eig_toimpute.dta" ,  replace





