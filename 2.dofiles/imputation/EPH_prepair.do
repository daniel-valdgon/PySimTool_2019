
* prepair variable for imputation EPH 

use "$indivdta"   , clear

gen jefe= P03==1

// edad jefe

gen edad_jefe=P02    if  jefe==1 

// menor en el hogar

gen menor= P02<12

// sexo jefe

gen sexo= P06==1

gen sexo_jefe=sexo     if  jefe==1

// married jefe

gen married= P09==1

gen married_jefe= married  if  jefe==1

// años estudio

gen esco_jefe=   anoest  if jefe==1

replace esco_jefe=0  if esco_jefe==99

// ocupado

gen ocupado= CATE_PEA!=.

gen ocupado_jefe= ocupado  if jefe==1

// asalariado 

gen asalariado= CATE_PEA==1 | CATE_PEA==2 

gen asalariado_jefe= asalariado   if jefe==1

// cuenta propia 

gen cpropia= CATE_PEA==3 | CATE_PEA==4 

gen cpropia_jefe= cpropia  if jefe==1

// migrò   (5 años atras)

gen migro= P12!=.

gen migr_jefe=  migro   if jefe==1


// hh size

bys  UPM NVIVI NHOGA: gen hhsize=_N

collapse (max) FEX  hhsize migr_jefe cpropia_jefe asalariado_jefe ocupado_jefe esco_jefe married_jefe sexo_jefe edad_jefe  (sum) menores_hh=menor   , by(UPM NVIVI NHOGA)

tempfile hhvars

save `hhvars'


**********************************************************
*   Nivel de hogar
**********************************************************

use "$agg"   , clear

_ebin IPCM  [aw=FEX] ,nq(10) gen(deciles)

keep UPM NVIVI NHOGA deciles

tempfile hhdecs

save `hhdecs'



use "$hhdta"  , clear

foreach vars in  upm nvivi nhoga {
	
	local new_var=upper("`vars'")
	rename `vars' `new_var'
}


// tipo vivienda 

gen tipo_vivienda=0                     //  otro
replace tipo_vivienda=1    if v01==1    //casa rancho
replace tipo_vivienda=2    if v01==2    // apartamento 

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
replace agua=1   if v06==1      // Essap
replace agua=2   if v06==2      // SENASA
replace agua=3   if v06==3      //  Red comunitaria
replace agua=4   if v06==4      //  Privada
replace agua=5	 if v06==6       // Pozo con bomba 

// tenure 

gen v_propia= v16==1            // propia


// celular 

gen celular= v11b==1

// computadora

gen computadora=  v23a1==1 

// rural

gen rural= area==6

//dptorep

gen depto= dptorep 

replace depto=20     if   depto==6

keep UPM NVIVI NHOGA depto rural computadora celular v_propia agua numero_piezas tipo_vivienda techo


// merge hh vars

merge m:1 UPM NVIVI NHOGA using `hhvars'  , nogen

merge m:1 UPM NVIVI NHOGA using `hhdecs'  , nogen


gen fex=FEX

tempfile  eph_toimpute

save `eph_toimpute'


