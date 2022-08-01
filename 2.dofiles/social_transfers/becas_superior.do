** becas educacion superior
** author: juanp . baquero 

set seed 1234

gen random_var=runiform()

*** Parameters 

// Becas 


local beca_edsuperior=becas[3,2]
local qbeca_edsuperior= becas[3,1]


*** Becas - Educacion Superior 

// Ayuda Economica consistente en la suma de guaranies 800.000 (ochocientos) y 1.000.000 (un millon) por becario. 
// Total Beneficiarios/Presupuesto obligado 2019: 1701/1.360.800.000 y 3741/3.741.000.000;	

	
*** Caracteristicas del programa 

// potencial 

// ed08 = 12. Tecnica superior, 13. Formacion Docente, 14 Prof Docente (Not included), 15. Formacion Militar, 16. Universitario, 17. Post-superior No universitario, 18. POst-Superior UNiversitario
// ed09 = 1. Publica 2 Privada 3 Privada subvencionada 

gen potencial =  (ed08 == 12 | ed08 == 13 | (ed08 >= 15 & ed08 <= 18)) /// 
				 & ed09 == 1    // inst privada ;  Educacion media ;  



// target people 

scalar target_ben=  `qbeca_edsuperior'
	
mata: n=st_numscalar("target_ben")  //  Se lee el  numero del target en mata y se le llama "n"

// potential beneficiaries

gen potential= (ed08 == 12 | ed08 == 13 | (ed08 >= 15 & ed08 <= 18)) & ed09 == 1                           //  se genera una variable de unos para todos los que son potenciales beneficiarios 

gen selector=1    if   (ed08 == 12 | ed08 == 13 | (ed08 >= 15 & ed08 <= 18)) & ed09 == 1                     //  se genera una variable de unos para todos los que son potenciales beneficiarios 

gen selector_w=fex    if  (ed08 == 12 | ed08 == 13 | (ed08 >= 15 & ed08 <= 18)) & ed09 == 1             //  se genera una variable de unos para todos los que son potenciales beneficiarios 

mata : st_view(xx=., ., "selector","potential")     // load all rows of selector for value where potential is not ==0 , remeberif you modify xx it will modify the dataset 

mata : vv=st_data(., "selector_w random_var","potential") // load all rows of selector_w random_var where potential is not missing in a stata matrix vv

mata : original_order=range(1,rows(vv),1) // returns a column vector from 1 to the rows of vv in steps of 1 (i.e delta=1)

mata:  aux=vv,original_order

mata: aux=sort(aux,2) // sort aux by the colum 2 of aux (random_var) 

mata: z=runningsum(aux[.,1]) :< J(rows(aux),1,n) // cumulative sum of first colum of aux is element wise lower than a J matrix (aux rows, 1 colum, filled with value n)

mata: z=z,aux

mata: z=sort(z,4) // sort z by the original index
	
mata: xx[.,1]=z[.,1] // remeber that xx will modify the dataset 

replace selector=0  if selector==.


*** Assign amount

gen monto_becsup= (`beca_edsuperior')/12    if selector==1

drop selector potential selector_w potencial 






