*===============================================================================
// MACROS
*===============================================================================
local _min_wage $min_wage
local _salud    $salud

local jloss_1 $jloss_1
local gcprv2020_   $gcprv2020_
local pytyvo1_ $pytyvo1_
local pytyvo2_ $pytyvo2_
local nangareko_ $nangareko_
local gasto_social2 $gtsocial_2
local perc_gasto_social2 $perc_gtsocial_2
local gcprv2021_   $gcprv2021_
local psstr2021_   $psstr2021_
local gasto_social3 $gtsocial_3
local gcprv2022_   $gcprv2022_
local psstr2022_   $psstr2022_
local gasto_social4 $gtsocial_4
local pytyvo22021_  $pytyvo22021_


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

//Tax contribution dummy	
	gen pago_labor = (labor_tax !=0 & ~missing(labor_tax)) 
	gen pago_uprod = (uprod_tax !=0 & ~missing(uprod_tax))
	gen pago_alquiler   = alquiler_tax!=0 & ~missing(alquiler_tax)
	gen pago_dividendo  = dividendo_tax!=0 & ~missing(dividendo_tax)
	gen pago_iragro = iragro!=0 & ~missing(iragro)
	gen pago_iracis = iracis!=0 & ~missing(iracis)
	
	gen pago_irp = (pago_labor==1 | pago_alquiler==1 | pago_dividendo==1)
	gen pago_dit = (pago_irp==1 | pago_uprod==1)
    gen pago_corp = (pago_dit==1 | pago_iragro==1 | pago_iracis==1 )
	gen pago_ire = (pago_iragro==1 | pago_iracis==1 | pago_uprod==1)
	
		lab var pago_labor "Contribuye impuesto laboral IRP"
		lab var pago_uprod "Contribuye impuestos por UProductiva"
		lab var pago_alquiler "Contribuye impuesto por alquiler"
		lab var pago_dividendo "Contribuye impuesto por dividendo"
		lab var pago_iragro "Conctribuye iragro"
		lab var pago_iracis "Contribuye iracis"
		lab var pago_irp "Contribuye al IRP (Trabajo o Capital)"
		lab var pago_dit "Contribuye impuesto directo (Trabajo, capital or Uprod)"
	    lab var pago_corp "Contribuye impuesto directo + impuestos corporativos"
	    lab var pago_ire "Contribuye impuestos corporativos"
	
*===============================================================================
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
			lab var rango_ingreso "Rangos ingresos"
			
	levelsof rango_ingreso, local(miwages_inc)
	foreach x of local miwages_inc{
		gen minwage_`x' = rango_ingreso==`x'
	}
		lab var minwage_1 "0-2 min wages"
		lab var minwage_2 "2-3 min wages"
		lab var minwage_3 "3-6 min wages"
		lab var minwage_4 "6-10 min wages"
		lab var minwage_5 "10 plus min wages"

*===============================================================================
// Obtaining the Income concepts and removing taxes....
*===============================================================================
//dis as error "GrMI: `mis_ing' tot_inc_capital `other_mkt_incs' rent_inc pension_inc `jefe_incs' salud_inc `private_transfers' ssc"
	
//Gross market income...must match across methods
//Note that mis_ing have already discounted SSC -> We add it back in here

	egen double gross_mkt_inc = rsum(`mis_ing' `other_mkt_incs' `capital_incs' rent_inc pension_inc `jefe_incs' salud_inc `private_transfers' ssc)


//Net market income
	//Remove the different tax components...
	gen double net_mkt_incirp = gross_mkt_inc - labor_tax   if ~missing(labor_tax)
	replace    net_mkt_incirp = net_mkt_inc   - alquiler_tax if ~missing(alquiler_tax)
	replace    net_mkt_incirp = net_mkt_inc   - dividendo_tax if ~missing(dividendo_tax)
		
	//Net market income of IRP and SSC
	gen double net_mkt_inc_irpssc = net_mkt_incirp - ssc if ~missing(ssc)
	
			
	// Total PIT
	egen double tot_pit = rsum(labor_tax dividendo_tax alquiler_tax)	
	egen double tot_dit = rsum(tot_pit uprod_tax) 
    egen double tot_dit_corp = rsum(tot_dit iragro iracis)
	egen double tot_ire = rsum(iragro iracis uprod_tax)
	
//Taxable incomes
	egen double taxable_income = rsum(_mylab_inc tot_inc_alquiler tot_inc_dividendo tot_inc_uprod baseiragro baseiracis )
    egen double taxable_income_irp= rsum(_mylab_inc tot_inc_alquiler tot_inc_dividendo)
	
	lab var gross_mkt_inc "Gross market income"
	lab var net_mkt_inc_irp "Market income net of IRP & SSC"
	lab var tot_pit "Total IRP - labor, dividend, rent"
	lab var tot_dit "Total direct tax - IRP + Uprod"
	lab var tot_dit_corp "Total direct tax: IRP + UPROD + IRAGRO + IRACIS"
    lab var tot_ire "Total corporate tax: IRAGRO + IRACIS + UPROD"
	lab var taxable_income "Total taxable income before deductions - includes labor, capital, dividendo, iragro, iracis & uprod"
    lab var taxable_income_irp "Total taxable income - includes labor, capital, dividendo"
	
	// in order to run both regimes without a problem 
	
	
	
/*	
	
	*save "$data_pry\indiv_level_sim.dta", replace 
	
*tempfile    indiv_level_sim
*save `indiv_level_sim'


//POVERTY RATE IN 2020 WITH COVID-19 AND  MITIGATION MEASURES
 if ($simyear== 2020){

 
 replace ipcm = ipcm * 0.965
//Independent worker urban area

gen independent_target=(b12==3 |  c09==3 ) & area==1
tabstat independent_target [w=fex], stat(sum)
sum independent_target [w=fex] if independent_target==1
di "El numero de empleador o patron en area urbana es: " `r(sum_w)' //149649 people
scalar y = `jloss_1'/`r(sum_w)'
di y
set seed 100000
gen independentworker=(uniform() <= y) if independent_target==1
sum independentworker [w=fex] if independentworker==1 


gen independentroverall= (independent_target==1)



//Private worker rural area
gen privworker_target2=(b12==2  & area==6)
tabstat privworker_target2 [w=fex], stat(sum)
sum privworker_target2 [w=fex] if privworker_target2==1
di "El numero de empleados privados en area urbana es: " `r(sum_w)' //355405
scalar c = 40136/`r(sum_w)'
di c 
set seed 300000
gen privworker2=(uniform() <= c) if privworker_target2==1
sum privworker2 [w=fex] if privworker2==1

gen privworkeroverall2= privworker2==0 & privworker_target2==1




* Gen Pytyvo beneficiaries
gen cuenta_prop=(b12==4 & (e01lde==0 | e01ide==0 | e01kde==0) &  peaa==1)

* Gen Pytyvo2 beneficiaries
gen cuenta_prop2=(b12==4 &  (b02rec==5 | b02rec==8 | b02rec==1) & peaa==1  )



* Zero income for those who lost their jobs
replace e01aimdeb2=0 if  independentroverall==1 

gen benefpytyvo1 = (b12==4 & (e01lde==0 | e01jde==0 ) & peaa==1 )

gen pytyvo1=((`pytyvo1_'/12))*benefpytyvo1

gen pytyvo2= ((`pytyvo2_'/12))*cuenta_prop2

//Nangareko benefit
* Beneficiary households (we assume that the transfer is per household)
gen beneficiary=(p02>18 & ( e01hde==0 | e01ide==0 | e01jde==0 | e01kde==0) & cuenta_prop==1 & pobrezai<3)

* An identifier to see if the household is beneficiary
egen x=sum(beneficiary), by (famunit)

* We define beneficiaries at household level
replace beneficiary=1 if x>0 &  p03==1
replace beneficiary=0 if x>0 &  p03!=1
drop x

* Asigning the ammount of the transfer to one person in the household (household head )

gen double covid_transf = (`nangareko_'/12)*beneficiary

* Calculating covid income  by household
egen x=sum(covid_transf), by(famunit)
gen hh_covid_transf = x/totpers
drop x

* Generating household incomes

egen hh_pytyvo1=sum(pytyvo1), by(famunit)
egen hh_pytyvo2=sum(pytyvo2), by(famunit)


egen double income_comp = rsum( hh_pytyvo1 hh_pytyvo2 hh_covid_transf)

egen ipcm_new = rsum(income_comp ipcm)

replace ipcm=ipcm_new
drop ipcm_new

replace ipcm=ipcm*0.7 if privworkeroverall2==1

replace ipcm = ipcm*(1+`gasto_social2') if decili==1 | decili==2 

gen recibe_nangareko = (covid_transf!=0 & ~missing(covid_transf))
	gen recibe_pytyvo1   = (pytyvo1!=0 & ~missing(pytyvo1))
	gen recibe_pytyvo2   = (pytyvo2!=0 & ~missing(pytyvo2))


	*save "$data_pry\indiv_level_sim.dta", replace 
	tempfile    indiv_level_sim
	save `indiv_level_sim'
	
	*save "$datagini\indiv_2020.dta", replace
	tempfile    indiv_2020
	save `indiv_2020'
}

if ($simyear== 2021) {

replace ipcm = ipcm * 0.965

* Gen Pytyvo2 beneficiaries
gen cuenta_prop2=(b12==4 &  (b02rec==5 | b02rec==8 | b02rec==1) & peaa==1  )


//Private worker rural area
gen privworker_target2=(b12==2  & area==6)
tabstat privworker_target2 [w=fex], stat(sum)
sum privworker_target2 [w=fex] if privworker_target2==1
di "El numero de empleados privados en area urbana es: " `r(sum_w)' //355405
scalar c = 40136/`r(sum_w)'
di c 
set seed 300000
gen privworker2=(uniform() <= c) if privworker_target2==1
sum privworker2 [w=fex] if privworker2==1
gen privworkeroverall2= privworker2==0 & privworker_target2==1


* Zero income for those who lost their jobs
gen benefpytyvo1 = (b12==4 & (e01lde==0 | e01jde==0 ) & peaa==1 )

gen pytyvo1=((`pytyvo1_'/12))*benefpytyvo1

gen pytyvo2= ((`pytyvo2_'/12))*cuenta_prop2

//Nangareko benefit
* Beneficiary households (we assume that the transfer is per household)
gen beneficiary=(p02>18 & ( e01hde==0 | e01ide==0 | e01jde==0 | e01kde==0) & cuenta_prop==1 & pobrezai<3)

* An identifier to see if the household is beneficiary
egen x=sum(beneficiary), by (famunit)

* We define beneficiaries at household level
replace beneficiary=1 if x>0 &  p03==1
replace beneficiary=0 if x>0 &  p03!=1
drop x

* Asigning the ammount of the transfer to one person in the household (household head )

gen double covid_transf = (`nangareko_'/12)*beneficiary

* Calculating covid income  by household
egen x=sum(covid_transf), by(famunit)
gen hh_covid_transf = x/totpers
drop x

* Generating household incomes

egen hh_pytyvo1=sum(pytyvo1), by(famunit)
egen hh_pytyvo2=sum(pytyvo2), by(famunit)


egen double income_comp = rsum( hh_pytyvo1 hh_pytyvo2 hh_covid_transf)

egen ipcm_new = rsum(income_comp ipcm)

replace ipcm=ipcm_new
drop ipcm_new


replace ipcm=0.6 if privworkeroverall2==1


gen adj2021 = (1+(0.032)*0.5)

replace ipcm = ipcm * adj2021

gen pytyvo22021= ((`pytyvo22021_'/12))*cuenta_prop2
egen hh_pytyvo22021=sum(pytyvo22021), by(famunit)

egen double ipcm_new = rsum(ipcm hh_pytyvo22021)


replace ipcm=ipcm_new
drop ipcm_new

//replace ipcm = ipcm*(1+`gasto_social3') if decili==1 | decili==2 

gen recibe_pytyvo22021   = (pytyvo22021!=0 & ~missing(pytyvo22021))


*save "$data_pry\indiv_level_sim.dta", replace 

tempfile    indiv_level_sim
save `indiv_level_sim'

*save "$datagini\indiv_2021.dta", replace

tempfile    indiv_2021
save `indiv_2021'

}


if ($simyear== 2022) {

gen adj2022 = (1+(0.029)*0.7)



replace ipcm = ipcm * 0.965

* Gen Pytyvo2 beneficiaries
gen cuenta_prop2=(b12==4 &  (b02rec==5 | b02rec==8 | b02rec==1) & peaa==1  )


//Private worker rural area
gen privworker_target2=(b12==2  & area==6)
tabstat privworker_target2 [w=fex], stat(sum)
sum privworker_target2 [w=fex] if privworker_target2==1
di "El numero de empleados privados en area urbana es: " `r(sum_w)' //355405
scalar c = 40136/`r(sum_w)'
di c 
set seed 300000
gen privworker2=(uniform() <= c) if privworker_target2==1
sum privworker2 [w=fex] if privworker2==1
gen privworkeroverall2= privworker2==0 & privworker_target2==1


* Zero income for those who lost their jobs
gen benefpytyvo1 = (b12==4 & (e01lde==0 | e01jde==0 ) & peaa==1 )

gen pytyvo1=((`pytyvo1_'/12))*benefpytyvo1

gen pytyvo2= ((`pytyvo2_'/12))*cuenta_prop2

//Nangareko benefit
* Beneficiary households (we assume that the transfer is per household)
gen beneficiary=(p02>18 & ( e01hde==0 | e01ide==0 | e01jde==0 | e01kde==0) & cuenta_prop==1 & pobrezai<3)

* An identifier to see if the household is beneficiary
egen x=sum(beneficiary), by (famunit)

* We define beneficiaries at household level
replace beneficiary=1 if x>0 &  p03==1
replace beneficiary=0 if x>0 &  p03!=1
drop x

* Asigning the ammount of the transfer to one person in the household (household head )

gen double covid_transf = (`nangareko_'/12)*beneficiary

* Calculating covid income  by household
egen x=sum(covid_transf), by(famunit)
gen hh_covid_transf = x/totpers
drop x

* Generating household incomes

egen hh_pytyvo1=sum(pytyvo1), by(famunit)
egen hh_pytyvo2=sum(pytyvo2), by(famunit)


egen double income_comp = rsum( hh_pytyvo1 hh_pytyvo2 hh_covid_transf)

egen ipcm_new = rsum(income_comp ipcm)

replace ipcm=ipcm_new
drop ipcm_new


replace ipcm=ipcm*0.6 if privworkeroverall2==1


gen adj2021 = (1+(0.032)*0.5)

replace ipcm = ipcm * adj2021

gen pytyvo22021= ((`pytyvo22021_'/12))*cuenta_prop2
egen hh_pytyvo22021=sum(pytyvo22021), by(famunit)

egen double ipcm_new = rsum(ipcm hh_pytyvo22021)


replace ipcm=ipcm_new
drop ipcm_new

//replace ipcm = ipcm*(1+`gasto_social3') if decili==1 | decili==2 

gen recibe_pytyvo22021   = (pytyvo22021!=0 & ~missing(pytyvo22021))

replace ipcm= ipcm * adj2022

replace ipcm = ipcm*(1+`gasto_social4') if decili==1 | decili==2 

*save "$data_pry\indiv_level_sim.dta", replace 

tempfile    indiv_level_sim
save `indiv_level_sim'

*save "$datagini\indiv_2022.dta", replace

tempfile    indiv_2022
save `indiv_2022'

}



*else {

*save "$data_pry\indiv_level_sim.dta", replace 
*tempfile    indiv_level_sim
*save `indiv_level_sim'

*}



