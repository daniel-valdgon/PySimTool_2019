clear 
set more off


*===============================================================================
//Pull excel parameters
*===============================================================================

//Tax schedule
import excel using "$xls_pry", sheet(nonprog_tax) first clear
levelsof dothis, local(nonprog) 
global nonprog `nonprog' 	 	// `nonprog'= 1== new system 0= old system 
global dothis = `=dothis[1]' 	// `nonprog'= 1== new system 0= old system 
levelsof VAT, local(_vat)
global VAT `_vat'
levelsof salud, local(_salud)
global salud `_salud'
levelsof min_wage, local(_min_wage)
global min_wage `_min_wage'
levelsof deductmod2, local(_dedmod2)
global deductmod2 `_dedmod2'	
levelsof addtop, local(_addtop)
global addtop `_addtop'

//The below pulls information for the top income imputation
if (`_addtop'==1){
	foreach x of varlist n_add* n_weight* art_weight*{
		global `x' = `x'[1]
	}
}

//Deduction modifications
levelsof deductmod, local(_dedmod)
global deductmod `_dedmod'

if (`nonprog'==1) {
	levelsof year, local(_simyear)
	global simyear `_simyear'
	levelsof bracket, local(_bracket)
	global bracket `_bracket'

	levelsof ded_after, local(_ded_after) clean
	global ded_after `_ded_after'
	
	foreach x of local _bracket {
		levelsof min_threshold if bracket==`x', local(_min_t_`x') clean
			global min_t_`x' = `_min_t_`x''
		levelsof max_threshold if bracket==`x', local(_max_t_`x') clean
			global max_t_`x' = `_max_t_`x''
		levelsof rate          if bracket==`x', local(_rate_t_`x') clean
			global rate_t_`x' = `_rate_t_`x''
	}
	local _dedT = `_min_t_1'*`_min_wage'
	global dedT = `_dedT'
	

}
else{
	import excel using "$xls_pry", sheet(prog_tax) first clear
	
	levelsof min_threshold if rate!=0 | max_threshold!="0", local(_mins)
	global min_threshold `_mins'
	
	levelsof rate if rate!=0 | max_threshold!="0", local(_prog_rates)	clean
	global rate `_prog_rates'
	
	levelsof year, local(_simyear)
	global simyear `_simyear'

	levelsof ded_after, local(_ded_after) clean
	global ded_after `_ded_after'

	levelsof bracket if rate!=0 | max_threshold!="0", local(_bracket)
	global bracket `_bracket'
	
	foreach x of local _bracket{
		levelsof min_threshold if bracket==`x', local(_min_t_`x') clean
			global min_t_`x' = `_min_t_`x''
		levelsof max_threshold if bracket==`x', local(_max_t_`x') clean
			global max_t_`x' = `_max_t_`x''
		levelsof rate          if bracket==`x', local(_rate_t_`x') clean
			global rate_t_`x' = `_rate_t_`x''
	}
	
	local _prog_mins
	foreach x of local _mins{
		local nm = `x'/12 //convert to monthly
		local _prog_mins `_prog_mins' `nm'
	}
	global prog_mins `_prog_mins'
	
	levelsof max_threshold if rate==0 & bracket==1, local(_dedT) clean
	if ("`_dedT'"=="") local _dedT=0

	local _dedT = `_dedT'/12
	global dedT = `_dedT'
	
	local _dedmod = 4 //No adjustment to deductions
	
	global min_imp = min_imp[1]*1e6  //Minimo imponible, convertido a millones
	
	//Ventanas de liquidacion
	import excel using "$xls_pry", sheet(uprod) first clear
	
	levelsof bracket, local(_bracket2) 
	global bracket2 `_bracket2'
	
	local nn=_N
	
	forval z=1/`nn'{
		global min2_`z' = minthold[`z']
		global max2_`z' = maxthold[`z']
		global amt2_`z' = amt[`z']
	}
	
	global rate2    = rate[1]
	global deduct2  = deduct[1]
	global dividend = dividends[1]	 //dividendos
	global pr_rent  = rents_pr[1]    //Renta presunta por capital
	global r_rent   = rent_r[1]      //tasa aplicada a renta presunta por capital
	
}

//GDP
import excel using "$xls_pry", sheet(gdp) first clear
levelsof year if !missing(growthYOY), local(_myY)
levelsof passthru, local(_pthru)

dis " `_myY' "
local _myY: list sort _myY
dis " `_myY' "


local gy = 1

*This are cumulative growth rates from 2016
foreach x of local _myY {
	levelsof growthYOY if year==`x', local(_gy)
	local gy = (1+`_gy'*`_pthru')*`gy'
	local _adj`x' = `gy'
	global adj`x' = `gy'
}


//SSC
import excel using "$xls_pry", sheet(ssc) first clear
levelsof type, local(myssc) clean
foreach x of local myssc{
	levelsof rate if type=="`x'", local(_`x')
	global `x' `_`x''
}
global myssc `myssc'


//Deductions
import excel using "$xls_pry", sheet(deduction) first clear
levelsof type, local(myded) clean
global myded `myded'
levelsof type if dowhich==1, local(_dedtype) clean
global dedtype `_dedtype'
foreach x of local myded{
	levelsof amount if type=="`x'" & dowhich==1, local(_`x')
	global `x' `_`x''
}

if (`_dedmod'!=4  | `_dedmod2'!=4){
	import excel using "$irpfxl", sheet(Sheet1) clear first

	gen share_inver = mu_invest/mu_income
	gen share_ded   = mu_cons_new/mu_income
		lab var share_inver "Share investment deductions / income"
		lab var share_ded "Share consumption deductions / income"

	replace qtile = ceil(qtile/5) //transforms into ventiles
		lab var qtile "Ventil of admin tax records"
	
	groupfunction, mean(mu_* share_inver share_ded) min(min_*) max(max_*) by(qtile)
	
	
	levelsof qtile, local(_irpftile)	//saves indicator of ventil
	global irpftile `_irpftile'
	sort qtile
	foreach x of local _irpftile{
		global mu_ded_tot`x'  = mu_ded_tot[`x']						//mean total deduction by ventil
		global mu_invest`x'   = mu_invest[`x']						//mean investment deduciton by ventil
		global sh_invest`x'   = share_inver[`x']					//mean share investment/income by ventil
		global sh_inv_cons`x' = mu_invest[`x']/mu_ded_tot[`x']		//mean share investment/total deduction by ventil
		global sh_ded`x'      = share_ded[`x']						//mean share consumption deduction/income by ventil
		global mu_ded`x'      = mu_cons_new[`x']					//mean consumption deduction by ventil
			global max_tinc`x'    = max_income[`x']					//max income in ventil
			global max_invest`x'  = max_invest[`x']					//max investment deduciton in ventil
			global max_ded_tot`x' = max_ded_tot[`x']				//max total deduction in ventil
			global max_ded`x'     = max_cons_new[`x']				//max consumption deduciton in ventil
			
			global min_tinc`x'    = min_income[`x']					//min income in ventil 
	}
}


//ISC tax rate

//import excel using "$xls_pry", sheet(isc) first clear // isc
	
	//levelsof codigo, local(mycodigo)  //codigo del producto
	//foreach x of local mycodigo {
		//levelsof tasa_nueva if codigo==`x', local(c)
		//global isc_`x'=`c'	
//	}
	
	//foreach x of local mycodigo {
		//levelsof tasa_2019 if codigo==`x', local(d)
		//global oldisc_`x'=`d'
//	}

//Indirect effects ISC rates	
	
import excel using "$xls_pry", sheet(sectores_isc) first clear // isc
	
	levelsof sector_id, local(mysector)  //codigo del producto
	foreach x of local mysector {
		levelsof cambio_efectivo if sector_id==`x', local(e)
		global efectiveisc_`x'=`e'	
	}
	
// Poverty simulations

import excel using  "$xls_pry", sheet("prog_covid_hide")  clear first
mkmat amount    , mat(prog_covid)

import excel using  "$xls_pry", sheet("empleo_hide") clear first
mkmat cant  , mat(cant_trab)

import excel using  "$xls_pry", sheet("g_social") clear first
mkmat gasto  , mat(gasto_s)


** Subsidios y transferencias

global pytyvo1_ = prog_covid[1,1]
global pytyvo2_ = prog_covid[2,1]
global nangareko_ = prog_covid[4,1]
global pytyvo22021_ = prog_covid[3,1]

** Perdida de empleo

global jloss_1 = cant_trab[1,1]
global jloss_2 = cant_trab[2,1]
global jloss_3 = cant_trab[3,1]
global jloss_4 = cant_trab[4,1]
global jloss_5 = cant_trab[5,1]
global jloss_6 = cant_trab[6,1]
global jloss_7 = cant_trab[7,1]
global jloss_8 = cant_trab[8,1]

** Gasto total en programas sociales 

global gtsocial_1 = gasto_s[1,1]
global gtsocial_2 = gasto_s[2,1]
global gtsocial_3 = gasto_s[3,1]
global gtsocial_4 = gasto_s[4,1]

** Gini teorico

global gini_1 = 0.5
global gini_2 = 0.5
global gini_3 = 0.5
	
	
** Subsidio Ande 


import excel using "$xls_pry", sheet(ande) first clear
levelsof doande, local(ande)
global ande `ande'
dis `ande'
global doande = `=doande[1]'
dis `=doande[1]'

import excel using  "$xls_pry", sheet("ande_hide") first clear
mkmat kwh precio consumo  , mat(andematrix)

global sub2020 =  andematrix[1,3]
dis $sub2020
global sub2021_1 =    andematrix[2,1]
dis $sub2021_1
global sub2021_2 =    andematrix[3,1]
dis $sub2021_2
global sub2021_3 =    andematrix[4,1]
dis $sub2021_3

global th1 =   andematrix[2,3]
global th2 =   andematrix[3,3]
global th3 =   andematrix[4,3]


** load some matrixes 

import excel using  "$xls_pry", sheet("becas_hide") first clear
mkmat bene val , mat(becas)


import excel using  "$xls_pry", sheet("alimentacion_hide") first clear
drop if benef==.
mkmat benef amount , mat(alimen)

import excel using  "$xls_pry", sheet("utiles_hide") first clear
drop if benef==.
mkmat benef val , mat(utiles)


// tekopora y adulto mayor 


import excel using  "$xls_pry", sheet("teko_adult_hide") first clear
mkmat growth   , mat(growth_prog)

