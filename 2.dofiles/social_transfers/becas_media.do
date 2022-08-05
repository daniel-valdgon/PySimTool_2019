** becas educacion media
** author: juanp . baquero 

set seed 1234

gen random_var=runiform()

*** Parameters 

// Becas 

local beca_edmedia1= becas[1,2]
local qbeca_edmedia1= becas[1,1]

local beca_edmedia2= becas[2,2]
local qbeca_edmedia2= becas[2,1]


*** Becas - Educacion Media

// Ayuda Economica consistente en la suma de guaranies 800.000 (ochocientos) y 1.000.000 (un millon) por becario. 
// Total Beneficiarios/Presupuesto obligado 2019: 1701/1.360.800.000 y 3741/3.741.000.000;	

	
*** Caracteristicas del programa 

// potencial 

gen potencial =  ((ed08 > 2 & ed08 <= 5) | ed08 == 7 | ed08 == 8) & ed09 == 1                // inst privada ;  Educacion media ;  

// target people 

scalar target_ben=  `qbeca_edmedia1' +  `qbeca_edmedia2'
	
mata: n=st_numscalar("target_ben")                                                  //  Se lee el  numero del target en mata y se le llama "n"

// potential beneficiaries

gen potential= ((ed08 > 2 & ed08 <= 5) | ed08 == 7 | ed08 == 8) & ed09 == 1                            //  se genera una variable de unos para todos los que son potenciales beneficiarios 

gen selector=1    if   ((ed08 > 2 & ed08 <= 5) | ed08 == 7 | ed08 == 8) & ed09 == 1                      //  se genera una variable de unos para todos los que son potenciales beneficiarios 

gen selector_w=fex    if  ((ed08 > 2 & ed08 <= 5) | ed08 == 7 | ed08 == 8) & ed09 == 1                //  se genera una variable de unos para todos los que son potenciales beneficiarios 

mata : st_view(xx=., ., "selector","potential")     // se lee los potenciales beneficiarios en mata

mata : vv=st_data(., "selector_w random_var","potential")

mata : original_order=range(1,rows(vv),1)

mata:  aux=vv,original_order

mata: aux=sort(aux,2)

mata: z=runningsum(aux[.,1]) :< J(rows(aux),1,n) 

mata: z=z,aux

mata: z=sort(z,4)
	
mata: xx[.,1]=z[.,1]

replace selector=0  if selector==.


*** Assign amount

gen monto_becmed= (`beca_edmedia1' + `beca_edmedia2')/12    if selector==1

noi dis "`beca_edmedia1' , `beca_edmedia2' `qbeca_edmedia1'  `qbeca_edmedia2' "

drop selector potential selector_w potencial 







