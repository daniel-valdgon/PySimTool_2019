*===============================================================================
// MACROS
*===============================================================================

foreach x of global myssc{
	local _`x' = ${`x'}
	
	dis "`x' : `_`x''"
}


*===============================================================================
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
e02l1bde
e02l2bde
;

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


local _all_incomes mis_ing labor_incs pension_inc other_mkt_incs private_transfers jefe_incs transfers imp_rent;

#delimit cr 

*===============================================================================
// SSC
*===============================================================================
	//Get discount rates for each ssc type

	gen d_e01aimdeb2 = (1-(`_pension'/100+`_ssc'/100)) if b11 == 1
	replace  d_e01aimdeb2 = (1-(`_fiscal'/100)) if b11== 2
	replace  d_e01aimdeb2 = (1-(`_bancaria'/100)) if b11 == 3
	replace  d_e01aimdeb2 = (1-(`_municipal'/100)) if b11 == 4
	replace  d_e01aimdeb2 = 1 if b11>4
	
	gen d_e01bimdeb2 = (1-(`_pension'/100+`_ssc'/100)) if c08 == 1
	replace  d_e01bimdeb2 = (1-(`_fiscal'/100)) if c08 == 2
	replace  d_e01bimdeb2 = (1-(`_bancaria'/100)) if c08 == 3
	replace  d_e01bimdeb2 = (1-(`_municipal'/100)) if c08 == 4
	replace  d_e01bimdeb2 = 1 if c08>4
	
	gen byte d_e01cimde   = 1
	
	gen double ssc = 0
	foreach x of local mis_ing{
		clonevar _`x' = `x' //Save old variable before transformation
		replace ssc= ssc + (`x'-`x'*d_`x') if ~missing(`x')
		replace `x' = `x'*d_`x' if ~missing(`x')
	}

	lab var d_e01aimdeb2 "Labor income from primary occ - net of SSC"
	lab var d_e01bimdeb2 "Labor income from secondary occ - net of SSC"
	lab var d_e01cimde "Labor income from terciary occ - net of SSC"
