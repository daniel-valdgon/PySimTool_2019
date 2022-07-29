*===============================================================================
// MACROS
*===============================================================================
local _min_wage $min_wage
local _salud    $salud


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
local other_mkt_incs  `agro'; 

//Non categorized market income;
local jefe_incs
e01kjde;

//Imputed rents;
local imp_rent
v19ede;

// Private transfers;
local private_transfers 
e01fde
e02tde
;

//Other transfer incomes: e01ide(Tekopora), e01gde(divorcio o cuidado de hijos) e01kde(AM) e01lde(viveres de otras instituciones pub);
local transfers
e01ide
e01gde
e01kde
e01lde;

//These are labor income in NET of SSC (changed in SSC.do);
local mis_ing 
e01aimdeb2 
e01bimdeb2 
e01cimde;

local _all_incomes mis_ing labor_incs pension_inc other_mkt_incs private_transfers jefe_incs transfers imp_rent;

#delimit cr 

*===============================================================================

//Gen corporate tax variable
egen double tot_ire = rsum (iragro iracis irpc)

//Gen IRP + corporate
egen double tot_dit_corp = rsum(labor_tax iragro iracis irpc)


//Tax contribution dummy	
	gen pago_irp = labor_tax !=0 & ~missing(labor_tax)
		lab var pago_irp "Contribuyo al IRP"
	
	gen pago_iragro = iragro!=0 & ~missing(iragro)
		lab var pago_iragro "Contribuye al IRAGRO"
	
		
	gen pago_iracis = iracis!=0 & ~missing(iracis)
		lab var pago_iracis "Contribuye al IRACIS"
	
	gen pago_irpc   = irpc!=0 & ~missing(irpc)
		lab var pago_irpc "Contribuye al IRPC"
		
	gen pago_corp = (pago_irp==1 | pago_iragro==1 | pago_iracis==1 | pago_irpc==1)
		lab var pago_corp "Contribuye al IRP & Imp corporativos"
		
	gen pago_ire = (pago_iragro==1 | pago_iracis==1 | pago_irpc==1)
	    lab var pago_ire "Contribuye a impuestos corp"
		
*============================================================================
// get final incomes per capita
*===============================================================================
//gross market income
	gen salud_inc = 0
	replace salud_inc = (`_salud') if (s01a==3|s01b==3) & (b12==1|c09==1)
		lab var salud_inc "Private health insurance for public employees"
	
	//Min wage income ranges
	egen double rango_ingreso = rsum(`mis_ing')
	replace rango_ingreso = 1 if inrange(rango_ingreso, `=0+1e-5', `=`_min_wage' * 2')
	replace rango_ingreso = 2 if inrange(rango_ingreso, `=`_min_wage' * 2 + 1e-5', `=`_min_wage' * 3')
	replace rango_ingreso = 3 if inrange(rango_ingreso, `=`_min_wage' * 3 + 1e-5', `=`_min_wage' * 6')
	replace rango_ingreso = 4 if inrange(rango_ingreso, `=`_min_wage' * 6 + 1e-5', `=`_min_wage' * 10')
	replace rango_ingreso = 5 if inrange(rango_ingreso, `=`_min_wage' * 10 + 1e-5', . ) & ~missing(rango_ingreso)
		lab var rango_ingreso "Income brackets in minimum wages -based on labor income net of ssc"
			
	levelsof rango_ingreso, local(miwages_inc)
	foreach x of local miwages_inc{
		gen minwage_`x' = rango_ingreso==`x'
	}
		lab var minwage_1 "0-1 min wages"
		lab var minwage_2 "2-3 min wages"
		lab var minwage_3 "3-6 min wages"
		lab var minwage_4 "6-10 min wages"
		lab var minwage_5 "10 plus min wages"
		
//Note that mis_ing have already discounted SSC -> We add it back in here


	egen double gross_mkt_inc = rsum(`mis_ing' `other_mkt_incs' `capital_incs' rent_inc pension_inc `jefe_incs' salud_inc `private_transfers' ssc)

gen uprod_tax=0  
gen dividendo_tax=0
gen alquiler_tax=0
	
	//net market income -> Gross minus IRP taxes paid!
	gen double net_mkt_incirp = gross_mkt_inc - labor_tax if ~missing(labor_tax)

	// Total PIT
	egen double tot_pit = rsum(labor_tax )	
	egen double tot_dit = rsum(tot_pit uprod_tax)
	//net market income of IRP and SSC
	
	gen double net_mkt_inc_irpssc = net_mkt_incirp - ssc if ~missing(ssc)
	
//Taxable incomes
	egen double taxable_income = rsum(_mylab_inc baseiragro baseiracis baseirpc) //in current system includes labor, iragro, iracis, irpc	
	
	lab var gross_mkt_inc "Gross market income"
	lab var net_mkt_inc_irp "Market income net of IRP"
	lab var taxable_income "Total taxable income before deductions - includes labor, iragro, iracis & irpc"

*save "$data_pry\indiv_level_sim.dta", replace 

tempfile    indiv_level_sim
save `indiv_level_sim'
