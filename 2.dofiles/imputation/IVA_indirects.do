/*===================================================================================
project:       Paraguay Simulation Tool
Author:        Juan P. Baquero
E-email:       jbaquerovargas@worldbank.org
url:           
Dependencies:  World Bank
Do-File: Prepair_IO
------------------------------------------------------------------------------------
Creation Date:    11 Jan 2022 
Modification Date:   
Do-file version:    01
Output:             
===================================================================================*/



*****   ISC shock 


*import excel  "$xls_pry", sheet("share_combustibles") first clear      // Cargar tarifas y formalidad en la cadena
*mkmat Share , mat(share_ventas)
*mkmat PimprtacionPventa , mat(Pimp_share)
*mkmat shock_pv , mat(shock_fuels)



import excel  "$xls_pry", sheet("vat_rates_2019") first clear      // Cargar tarifas ISC

keep ga01c isc19  sectorio

rename sectorio  sector

tempfile data_II

save `data_II'



*****  VAT  shock

 
import excel  "$xls_pry", sheet("vat_rates_2019") first clear      // Cargar tarifas y formalidad en la cadena

keep ga01c iva19 exempted sectorio

rename sectorio  sector

tempfile data

save `data'


collapse (mean) iva19 , by(sector exempted)

*****   Create local of sectors that do not have a mixed case of exemption 

//  first we keep the sectors that have a mixed case of exemption   

collapse (mean) exempted (max) iva19, by(sector)

drop if sector==.

tempfile tasas

save `tasas'

levelsof sector if exempted!=0 , local(excluded)

keep if exempted!=0 & exempted!=1


// we store the sectors that have exempted and non exempted items 

levelsof sector ,  local(noncollsecs)     

// we store the sectors that do not have mixed cases 

local collsecs      

 foreach ii of numlist 1/40 {
 
 local  macname : list ii in noncollsecs
 
 dis(`macname')
 
 if (`macname')==0 {
 
 local  collsecs  `collsecs' `ii'
 }
 
 }
 
 dis("`collsecs'")
 
 
 *****   Create the extented IO only extending the Mixed sectors 
 
/// Import IO 

import excel  "$xls_pry", sheet("IOmatrix") first clear       // Cargar tarifas y formalidad en la cadena
keep sector*
drop if sector==.

// Store the IO in Mata 

mata: io=st_data(., "sector1-sector40",.) 

// Matrix of ceros 

mata: extended=J(40*2,40*2,0)   


// First we extended all the sectors 

mata: 

for(n=1; n<=40; n++)  {

jj=2*n-1
kk=jj+1


for(i=1; i<=40; i++)  {
j=2*i-1
k=j+1


extended[jj::kk,j::k]=J(2,2,io[n,i])/2

}
}

st_matrix("extended",extended)

end

clear

svmat extended

rename extended* sector_*

gen sector=ceil(_n/2)



// Second we collapse sectors that do not extend 


gen aux=.

foreach ii of local  collsecs {

replace  aux=1    if  sector==`ii'       // sectors that collapse 

}

replace aux=0 if aux==.

preserve 

keep if aux==0

tempfile nocollapse

save `nocollapse'

restore 

// second we keep the sectors that collapse and then append the sectors that do not collapse 

keep if aux==1    

collapse (sum) sector_1-sector_80 if aux==1 , by(sector)

append using `nocollapse'

sort sector


// finnaly we remove columns of the sectors that do not collapse 

drop aux

foreach var of local collsecs {

local ii =  `var'*2

drop sector_`ii'

}



// we identify excluded sectors 

gen exempted=0

foreach var of local excluded {

replace exempted=1   if   sector==`var'

}


bys sector:  gen aux_size=_n

replace exempted=0  if aux_size==2

drop aux_size

// we identify the fixed sectors: we follow the previous CEQ on this 

local thefixed 34 

gen fixed=0

foreach var of local thefixed {

replace fixed=1  if  sector==`var'

}


merge m:1 sector using `tasas'

replace iva19=0  if exempted==1

replace iva=0 if iva==.

gen cp=1-fixed

gen vatable=1-fixed-exempted

replace vatable=1  if vatable==-1

replace iva=iva/100

gen shock= - iva/(1+iva)

replace shock=0  if shock==.


gen indirect_effect_iva=0

mata : st_view(YY=., ., "indirect_effect_iva",.)
mata: XX=st_data(., "sector_1-sector_80",.)
mata: cp=st_data(., "cp",.)'
mata: shock=st_data(., "shock",.)'
mata: vatable=st_data(., "vatable",.)'		
mata: exempt=st_data(., "exempted",.)'


mata:  YY[.,.]=indirect(XX,cp,shock,vatable,exempt)'

replace indirect_effect_iva=0   if cp==0

keep sector indirect_effect_iva exempted

sum indirect_effect_iva

replace indirect=-indirect

tempfile indirect

save `indirect'


// Here we use the percentage shares of each IO sectors 

use `data' , clear

merge m:1 sector exempted using  `indirect'

drop if ga01c==.

drop _merge 

tempfile indirect_effects

format ga01c %12.0g

tempfile indirect_effects_IVA

save `indirect_effects_IVA'














