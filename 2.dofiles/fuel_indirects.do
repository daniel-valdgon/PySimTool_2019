
*******************************
* Indirect effects fuel excises
*******************************

// Fuel parameters

import excel  "$xls_pry", sheet("share_combustibles") first clear      // Cargar tarifas y formalidad en la cadena
mkmat Share , mat(share_ventas)
mkmat PimprtacionPventa , mat(Pimp_share)
mkmat shock_nafta shock_diesel , mat(shock_fuels)



// Import IO 

import excel  "$xls_pry", sheet("IOmatrix") first clear       // Cargar tarifas y formalidad en la cadena
keep sector*
drop if sector==.



// Excises change in price 

gen shock=0

replace shock=-shock_fuels[1,1]*share_ventas[1,1] -shock_fuels[1,2]*share_ventas[2,1]  if  sector==16       // Nafta Shock 

gen fixed=0

replace fixed=1     if sector==34

gen cp=1-fixed

gen move= shock!=0

gen pay=1-move

keep sector sector1-sector40  shock fixed

costpush sector1-sector40 , fixed(fixed) price(shock) genptot(totalfix) genpind(indirectfix) fix


/*
gen indirect_effect_fuels=.

mata : st_view(YY=., ., "indirect_effect_fuels",.)

mata: XX=st_data(., "sector1-sector40",.)
mata: cp=st_data(., "cp",.)'
mata: shock=st_data(., "shock",.)'
mata: move=st_data(., "move",.)'	
mata: pay=st_data(., "pay",.)'

mata:  YY[.,.]=indirect(XX,cp,shock,move,pay)'
*/

rename indirectfix indirect_effect_fuels

keep sector indirect_effect_fuels 

replace indirect_effect_fuels= - indirect_effect_fuels

tempfile indirect_fuels

save `indirect_fuels'







