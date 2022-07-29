** Alimentacion escolar 
** Author: Juanp. Baquero   based on Flavia Sacco  Emma Escobar 

*** Parameters 

local tfood_concepcion  = alimen[1,2]
local tfood_sanpedro    = alimen[2,2]
local tfood_cordillera  = alimen[3,2]
local tfood_guaira      = alimen[4,2]
local tfood_caaguazu    = alimen[5,2]
local tfood_caazapa     = alimen[6,2]
local tfood_itapua      = alimen[7,2]
local tfood_misiones    = alimen[8,2]
local tfood_paraguari   = alimen[9,2]
local tfood_altoparana  = alimen[10,2]
local tfood_central     = alimen[11,2]
local tfood_neembucu    = alimen[12,2]
local tfood_amambay     = alimen[13,2]
local tfood_canindeyu   = alimen[14,2]
local tfood_pdtehayes   = alimen[15,2]
local tfood_asuncion    = alimen[16,2]
local tfood_altoparaguay= alimen[17,2]

local qfood_concepcion  = alimen[1,1]
local qfood_sanpedro    = alimen[2,1]
local qfood_cordillera  = alimen[3,1]
local qfood_guaira      = alimen[4,1]
local qfood_caaguazu    = alimen[5,1]
local qfood_caazapa     = alimen[6,1]
local qfood_itapua      = alimen[7,1]
local qfood_misiones    = alimen[8,1]
local qfood_paraguari   = alimen[9,1]
local qfood_altoparana  = alimen[10,1]
local qfood_central     = alimen[11,1]
local qfood_neembucu    = alimen[12,1]
local qfood_amambay     = alimen[13,1]
local qfood_canindeyu   = alimen[14,1]
local qfood_pdtehayes   = alimen[15,1]
local qfood_asuncion    = alimen[16,1]
local qfood_altoparaguay= alimen[17,1]

*** Target

gen double edu_food=((ed11f1 == 1 | ed11f1a==1| ed11g1 == 1 | ed11g1a==1) & (ed08 == 1 | ed08 == 2 | ed08 == 6) & (ed09 == 1|ed09 == 3))   // recibe alimentacion y esta en colegio publico o privado subsidiado

* Imputar transferencias en especies por concepto de alimentos
gen double monto_transesp=0 

replace monto_transesp= (`tfood_concepcion'/`qfood_concepcion')/12  if dpto == 1 & edu_food==1

replace monto_transesp= (`tfood_sanpedro'/`qfood_sanpedro')/12      if dpto == 2 & edu_food==1

replace monto_transesp= (`tfood_cordillera'/`qfood_cordillera')/12  if dpto == 3 & edu_food==1

replace monto_transesp= (`tfood_guaira'/`qfood_guaira')/12          if dpto == 4 & edu_food==1

replace monto_transesp= (`tfood_caaguazu'/`qfood_caaguazu')/12      if dpto == 5 & edu_food==1

replace monto_transesp= (`tfood_caazapa'/`qfood_caazapa')/12        if dpto == 6 & edu_food==1

replace monto_transesp= (`tfood_itapua'/`qfood_itapua')/12          if dpto == 7 & edu_food==1
 
replace monto_transesp= (`tfood_misiones'/`qfood_misiones')/12      if dpto == 8 & edu_food==1

replace monto_transesp= (`tfood_paraguari'/`qfood_paraguari')/12    if dpto == 9 & edu_food==1

replace monto_transesp= (`tfood_altoparana'/`qfood_altoparana')/12  if dpto == 10 & edu_food==1
  
replace monto_transesp= (`tfood_central'/`qfood_central')/12        if dpto == 11 & edu_food==1
 
replace monto_transesp= (`tfood_neembucu'/`qfood_neembucu')/12      if dpto == 12 & edu_food==1

replace monto_transesp= (`tfood_amambay'/`qfood_amambay')/12        if dpto == 13 & edu_food==1

replace monto_transesp= (`tfood_canindeyu'/`qfood_canindeyu')/12    if dpto == 14 & edu_food==1

replace monto_transesp= (`tfood_pdtehayes'/`qfood_pdtehayes')/12    if dpto == 15 & edu_food==1
 
replace monto_transesp= (`tfood_asuncion'/`qfood_asuncion')/12      if dpto == 0 & edu_food==1


