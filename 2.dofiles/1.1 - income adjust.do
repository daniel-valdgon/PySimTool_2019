*===============================================================================
// MACROS
*===============================================================================
local _simyear = $simyear
local _adj`_simyear' = ${adj`_simyear'}


//Income classification locals
#delimit;

//Labor incomes - individual level - as reported in survey;
local labor_incs 
e01aimde 
e01bimde 
e01cimde;

//Pension and retirement incomes;
local pension_inc
e01hde
e01jde; 

//Capital incomes;
local alquiler 
e01dde; 
local dividendo 
e01ede;
local capital_incs `alquiler' `dividendo';

//Other market incomes from agro;
local agro 
e01mde; 

// All other market incomes;
local other_mkt_incs `alquiler' `dividendo' `agro'; 

//Non categorized market income;
local jefe_incs
e01kjde;

//Imputed rents;
local imp_rent
v19ede;

// Private transfers;
local private_transfers 
e01fde
e02tde;

//Ingresos para iragro, iracis, irpc
local ing_dirtax 
iragro
iracis
irpc;

//Other transfer incomes: e01ide(Tekopora), e01gde(divorcio o cuidado de hijos) e01kde(AM) e01lde(viveres de otras instituciones pub);
local transfers
e01ide
e01gde
e01kde
e01lde;

//These are labor income in gross terms including SSC;
local mis_ing 
e01aimdeb2 
e01bimdeb2 
e01cimde;



local _all_incomes mis_ing labor_incs pension_inc other_mkt_incs private_transfers jefe_incs transfers imp_rent ing_dirtax ;

#delimit cr 

*===============================================================================
// for simulation years adjust all incomes
*===============================================================================
	replace ipcm = ipcm * `_adj`_simyear''
	foreach x of local _all_incomes{
		foreach y of local `x'{
			replace `y' = `y'*`_adj`_simyear''
		}	
	}

	
	
		
