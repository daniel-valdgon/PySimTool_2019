set more off
clear all

if (upper("`c(username)'")!="WB378870"){
	if (upper("`c(username)'")=="WB334916") global path "C:\Users\\`c(username)'\OneDrive - WBG\WB_GF\2.PovLAC\LC7_PY\4.CEQ\3. PySim2016\PySimTool\"
	else global path "C:\Users\\`c(username)'\WBG\Maria Gabriela Farfan Betran - 4.CEQ\3. PySim2016\PySimTool\"
}
else{
	global path "C:\Users\WB378870\Documents\PySimTool\"
}
*===============================================================================
//
// DO NOT MODIFY BEYOND THIS POINT
//
*===============================================================================
global data_pry "$path\1.Data"
global indivdta "$data_pry\data_prep_individuo.dta"
global xls_pry  "$path\3.Tool\PYsim.xls"
global irpfxl   "$data_pry\irpf.xlsx"
global thedo    "$path\\2.dofiles"                 
global simpath  "$data_arg\_thesim\"  


//Income classification locals
#delimit;
//Labor incomes;
local labor_incs 
e01aimde 
e01bimde 
e01cimde;

//Pension and retirement incomes;
local pension_inc
e01hde
e01jde; 

//Other market incomes;
local other_mkt_incs e01dde e01ede e01mde;

local private_transfers //changed the variable e02tde by the two variables e02l1bde e02l2bde, which are the equivalents in the individual data file
e01fde
e02l1bde
e02l2bde
;

//Non categorized market income;
local jefe_incs
e01kjde;

//Imputed rents;
local imp_rent
v19ede;

//Transfer incomes e01gde: prestaciones por divorcio o cuidado de hijos ???;
local transfers
e01ide
e01gde
e01kde
e01lde;

//These are in gross terms including SSC;
local mis_ing e01aimdeb2 e01bimdeb2 e01cimde;
 
local _all_incomes mis_ing labor_incs pension_inc other_mkt_incs private_transfers jefe_incs transfers imp_rent;

local all e01aimde	e01bimde	e01cimde	e01dde	e01ede	e01fde	e01hde	e01jde 	e01ide	e01gde	e01mde	e01kde	e01lde	e02tde	v19ede	e01kjde;

#delimit cr 

*===============================================================================
//1. Bring in the admin data
*===============================================================================
import excel using "$irpfxl", sheet(Sheet1) first clear
keep if qtile>80

//replace qtile = ceil(_n/2)

groupfunction , mean(mu_income ) by(qtile) 

sort qtile
replace qtile = _n

tempfile admin
save `admin'

*===============================================================================
//2. Select random hh to add top incs
*===============================================================================


use "$indivdta", clear
sort famunit l02
egen double gross_inc = rsum(`mis_ing' `other_mkt_incs')
replace gross_inc = 0 if (grava_irp1==0)&(grava_irp2==0)&(grava_irp3==0)

replace gross_inc = gross_inc + (1e10)*_n if gross_inc!=0
gsort -gross_inc
keep if _n<=100

set seed 83474
//randomly select 100 
gen x = runiform()

gen ratio =e01aimdeb2/e01aimde

sort x
keep famunit l02 `mis_ing' `other_mkt_incs' grava_irp* gravairp* gross_inc totpers ratio `all' ipcm fex area
order famunit l02 `mis_ing' `other_mkt_incs' grava*


keep if _n<=20 
sort gross_inc

egen _myall = rsum(`all')
replace ipcm = ipcm - _myall/totpers
drop _myall
local all : list all - mis_ing
local all : list all - other_mkt_incs
drop `all'	

local theincs mis_ing other_mkt_incs

foreach x of local theincs{
	foreach y of local `x'{
		replace `y' =0
	}
}

foreach x of varlist grava_irp* gravairp*{
	replace `x' = 0
}
replace grava_irp1 = 1
replace gravairp_emppriv1=1

//Now take each observation, modify the main income
gen qtile = _n


replace fex = 210 if _n>18

merge 1:1 qtile using `admin'
	drop if _m==2
	drop _m
	

replace e01aimdeb2 = mu_income*1e6/12

replace ipcm = ipcm + (e01aimdeb2/totpers)/ratio

levelsof qtile, local(myobs)
sort qtile

tempfile mydata
save `mydata'


qui{
foreach i of local myobs{
	use `mydata', clear
	keep if _n==`i'
	
	levelsof famunit, local(myfam) clean
	levelsof l02, local(mypeeps) clean
	levelsof fex, local(myw)
	local ipcm = ipcm[1]
	
	tempfile obb
	save `obb' 
	
	use "$indivdta", clear
		gen ratio =e01aimdeb2/e01aimde
		keep if famunit == "`myfam'"
		drop if l02 == `mypeeps'
		
		append using `obb'
		replace fex = `myw'
		replace ipcm = `ipcm'
		
	replace famunit = "new_`i'"
	tempfile _`i'
	save `_`i''
	
	local mynew `mynew' _`i'
}
}

tokenize `mynew'
use ``1'', clear

macro shift
local rest `*'

foreach x of local rest{
		qui:append using ``x''
}

save "$data_pry/topincs.dta", replace











