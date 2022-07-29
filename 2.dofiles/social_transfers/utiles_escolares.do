** Utiles escolares 
** Author: Juanp. Baquero   based on Flavia Sacco  Emma Escobar 

*** Parameters 

local stransf_utiles=utiles[1,2]
local qtransf_utiles=utiles[1,1]


*** Target

gen double eduuti=(ed09 == 1 | ed09 == 3) & (ed11b1 == 1 | ed11b2==1 | ed11b3==1 | ed11b4==1 | ed11b5==1 | ed11b6==1 | ed11b7==1 | ed11b8==1 | ed11b9==1)  // utiles escolares


* Imputar transferencias en especies por concepto de alimentos
gen double monto_utiles=0 

gen     monto_transutil=((`stransf_utiles' / `qtransf_utiles' ) / 12)  if eduuti==1

