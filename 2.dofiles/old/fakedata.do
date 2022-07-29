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

#delimit cr 

*===============================================================================
//1. Bring in the admin data
*===============================================================================
import excel using "$irpfxl", sheet(Sheet1) first clear
keep if qtile>80

replace qtile = ceil(_n/2)

groupfunction , mean(mu_income ) by(qtile) 

tempfile admin
save `admin'

*===============================================================================
//1. Bring in indiv data and create 10 new observations
*===============================================================================

use "$indivdta", clear

drop upm nvivi nhoga p03 p04 p04a p04b p05c p05p p05m p08d p08m p08a p09 p10a ///
p10ab p10z p11a p11ab p11z p12 a01 a01a a02 a03 a04 a04a a05 a07 a08 a10 a11a a11m ///
a11s a12 a13rec a14rec a15 a16 a17a a17m a17s a18 b01c b01rec b02d b02c b02rec ///
b03lu b03ma b03mi b03ju b03vi b03sa b03do b04 b05 b06 b07a b07m b07s b08 b09a ///
b09m b09s b10 b13 b14 b15 b16g b16u b16d b16t b17 b18ag b18au b18bg b18bu ///
b19 b20g b20u b20d b20t b21 b22 b23 b24 b25 b26 b271 b272 b28 b29 b30 b31 c01c c02rec ///
c03 c04 c05 c06 c07 c101 c102 c11g c11u c11d c11t c12 c13ag c13au c13bg c13bu ///
c14 c14a c14b c14c c15 c16c c17rec c18 c18a c18b c19 d01 d02 d03 d04 d05 e01a ///
e01b e01c e01d e01e e01f e01g e01h e01i e01j e01k e01l e01m ed01 ed02 ed03 ed0504 ///
ed06c ed08 ed09 ed10 ed11a ed11b ed11c ed11d ed11e ed11f ed12 ed13 ed14a ed14 ///
ed15  s02 s03 s04 s05 s06 s07 s08 s09 cate_pea tama_pea ocup_pea rama_pea ///
horab horabc horabco pead peaa tipohoga njef ncon npad nmad tic01 tic02 tic03 ///
tic0401 tic0402 tic0403 tic0404 tic0405 tic0406 tic0407 tic0408 tic0409 tic0501 ///
tic0502 tic0503 tic0504 tic0505 tic0506 tic0507 tic0508 tic0509 tic0510 tic0511 ///
tic0512 tic0513 tic06 anioest ra06ya09 marco pobrezai pobnopoi quintili quintiai ///
decilai b01d jefe menores menores_hh ing_imp decil_persona hijo hijo_h pareja ///
pareja_h papa mama papa_solviu mama_solviu separado mayores60 jefes_dis nojefes_dis ///
ed_jefes papa_solviu_h mama_solviu_h separado_h jefes_dis_h nojefes_dis_h ed_jefes_h ///
mayores60_hh men_teredad_h PMT ips contpri contsec contpri2 contsec2 salud_count ///
salud_count_hh salud_sub salud_sub_hh ing_especie1 irpc5220b cod_ocuirp2 sociedad2 ///
irpc5220c cod_ocuirp3 tot_asalariados tot_empleadores_cuent ingrevasode bonode ///
v21gde ingrem autocneto_hh autocneto_j y

		
gen old=1

local nn = _N + 10
set obs `nn'

keep if old!=1
//varlist to replace:
foreach x of local _all_incomes{
	foreach y of local `x'{
	replace `y' = 0 
	}
}

replace area       = 1 
replace dptorep    = 0 
replace dpto       = 0
replace dpto_decile= 10
replace ipcm       = 0
replace b11        = 1
replace grava_irp1 = 1
replace grava_irp2 = 0
replace grava_irp3 = 0
replace grava_iva1 = 0
replace grava_iva2 = 0


replace totpers=1  //We assume all these people are single!
replace miembros=1

replace p06 = 1
replace p02 = 55
replace l02 = 1

replace fex = 220 if _n<=5
replace fex = 840 if _n> 5

gen qtile = _n

replace famunit = "99999"+string(_n)+"old"

merge 1:1 qtile using `admin'
	drop if _m==2
	drop _m
	
replace e01aimdeb2 = mu_income*1e6/12
replace ipcm = e01aimdeb2

drop qtile

save "$data_pry/topincs.dta", replace

