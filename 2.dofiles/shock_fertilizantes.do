// Import IO 

import excel  "$xls_pry", sheet("IOmatrix") first clear       // Cargar tarifas y formalidad en la cadena
keep sector*
drop if sector==.




*****  Price shock 

gen dp= 0

replace dp= 0.01    if  sector==18           // shock in otros productos quimicos no farmaceuticos


// fixed sectors 

local thefixed 34

gen fixed=0

foreach var of local thefixed {

replace fixed=1  if  sector==`var'

}	

costpush sector1-sector40 , fixed(fixed) price(dp) genptot(totalfix) genpind(indirectfix) fix

keep if sector==1

keep indirectfix    // nos quedamos solo con el efecto sobre agricultura 


