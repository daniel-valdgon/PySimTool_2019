

use `eph_toimpute'   , clear

tempfile part_II

save `part_II'



*****************************
*  Diesel Share
*****************************
** Load eig and merge  imputation variables 

*use "$data\cons_tax.dta"  , clear  

use `cons_tax'  , clear  

merge 1:1 UPM NVIVI NHOGA using `eig_toimpute'

keep if _merge==3

gen eig=1

append using  `part_II'

replace eig=0 if eig==.


// generete dummies 

ta tipo_vivienda , gen(tipoviv)

ta techo  , gen(techo_)

ta agua    , gen(agua_)

ta depto   , gen(depto_)

ta deciles , gen(_deciles)


sum edad_jefe sexo_jefe tipoviv2 tipoviv3 numero_piezas techo_2-techo_5 agua_2- agua_6 v_propia celular computadora rural depto_2- depto_7 hhsize ///
 migr_jefe cpropia_jefe asalariado_jefe ocupado_jefe esco_jefe married_jefe  menores_hh _deciles2- _deciles10 if eig==1

sum edad_jefe sexo_jefe tipoviv2 tipoviv3 numero_piezas techo_2-techo_5 agua_2- agua_6 v_propia celular computadora rural depto_2- depto_7 hhsize ///
 migr_jefe cpropia_jefe asalariado_jefe ocupado_jefe esco_jefe married_jefe  menores_hh _deciles2- _deciles10 if eig==0

********* Regression

// Dependent variables

global xvar edad_jefe sexo_jefe tipoviv2 tipoviv3 numero_piezas techo_2-techo_5 agua_2- agua_6 v_propia celular computadora rural depto_2- depto_7 hhsize ///
 migr_jefe cpropia_jefe asalariado_jefe ocupado_jefe esco_jefe married_jefe  menores_hh _deciles2- _deciles10

*reg kwh $xvar  if engho==1

gen eph = eig==0

* igv share

*gen igv_s=  (igv/TamHog)/ disposable_income_pc 

*drop if (igv_s >1) & eig==1

reg ratio_diesel $xvar  [aw=fex] if eig==1 

predict fitted  if eig==1 

*predict theresid if eig==1  , resid

*sum theresid

*replace fitted= fitted 


*replace theresid=exp(theresid)

*sum theresid

gen y_imputed=0   if eig==0

mata : st_view(MM=., ., "y_imputed","eph")


// bootstraping samples 

forvalues ii=1/500 {

preserve 

keep if eig==1

bsample 

* qui reg lkwh $xvar  

qui reg ratio_diesel $xvar [aw=fex]  

predict theresid_simu  , resid

*replace theresid_simu=exp(theresid_simu)

sum theresid_simu

scalar  thesd=r(sd)

mat betas=e(b)

scalar themean=r(mean)

restore 

mat score y = betas if eig==0


mata : y=st_data(., "y","eph")

if (`ii')==1 {


mata: Y_boots= y 

}

else {

mata: Y_boots= Y_boots, y 


}

drop y

}


// Hasta aca tenemos 500 estimaciones del ratio para cada observacion de la eph

mata:  index=imp=(ceil(500*runiform(rows(y),1)))

mata: index= J(1,500,index)

mata: c=1::500

mata: c=c'

mata: c=J(rows(y),1,c)

mata:  loc = index:==c

mata: imput=rowsum(Y_boots:*loc)

mata: MM[.,.]=imput

gen theobs=_n

preserve

mata : y_eph=st_data(., "y_imputed theobs","eph")

mata : y_engho=st_data(., "fitted theobs hhid","eig")

mata: y_eph=sort(y_eph,1)

mata: y_engho=sort(y_engho,1)

mata:  y_eph=  y_eph, J(rows(y_eph),5,0)

mata: loc_min=(J(rows(y_engho),1,y_eph[100,1]) :>= y_engho[.,1])

mata: loc_max=(J(rows(y_engho),1,y_eph[1,1]) :< y_engho[.,1])

mata: 


for (i=1; i<=rows(y_eph); i++)   {

loc_min=(J(rows(y_engho),1,y_eph[i,1]) :>= y_engho[.,1])

if (sum(loc_min)==0 | sum(loc_min)==1) {

y_eph[i,3::7]= y_engho[1::5,3]'

}


if (sum(loc_min)==2) {

y_eph[i,3::7]= y_engho[2::6,3]'

} 


if (sum(loc_min)>2 & sum(loc_min)<rows(y_engho)-1    ) {

y_eph[i,3::7]= y_engho[(sum(loc_min)-2)::(sum(loc_min)+2),3]'

}


if ( sum(loc_min)>=rows(y_engho)-1    ) {

y_eph[i,3::7]= y_engho[rows(y_engho)-4::rows(y_engho),3]'

}

}

end


mata: st_matrix("y_eph",y_eph)

clear

svmat y_eph 

rename y_eph2 theobs

keep theobs y_eph3-y_eph7

tempfile imputation

save `imputation'

restore

merge 1:1 theobs using `imputation'  , nogen

rename y_eph3 _1_v1
rename y_eph4 _2_v1
rename y_eph5 _3_v1
rename y_eph6 _4_v1
rename y_eph7 _5_v1

gen x = int(runiform(1,6))

gen     imputed_diesel_v1= _1_v1    if x==1

replace imputed_diesel_v1= _2_v1    if x==2

replace imputed_diesel_v1= _3_v1    if x==3

replace imputed_diesel_v1= _4_v1    if x==4

replace imputed_diesel_v1= _5_v1    if x==5

*sum imputed_igv_s if eig==0

keep if eig==0

keep UPM NVIVI NHOGA imputed_diesel_v1

// this is to merge with flavia datasets 

rename UPM upm
rename NVIVI nvivi
rename NHOGA nhoga

foreach var in upm nvivi nhoga {
	tostring `var', replace
	replace `var'=`var' + "X" if length(`var')==2
	replace `var'=`var' + "XX" if length(`var')==1
}
egen double famunit=concat(upm nvivi nhoga)

*save "$data\imp_igv.dta" ,replace 
tempfile imp_diesel

save `imp_diesel'



*****************************
*  Nafta Share
*****************************
** Load eig and merge  imputation variables 

*use "$data\cons_tax.dta"  , clear  

use `cons_tax'  , clear  

merge 1:1 UPM NVIVI NHOGA using `eig_toimpute'

keep if _merge==3

gen eig=1

append using  `part_II'

replace eig=0 if eig==.


// generete dummies 

ta tipo_vivienda , gen(tipoviv)

ta techo  , gen(techo_)

ta agua    , gen(agua_)

ta depto   , gen(depto_)

ta deciles , gen(_deciles)


sum edad_jefe sexo_jefe tipoviv2 tipoviv3 numero_piezas techo_2-techo_5 agua_2- agua_6 v_propia celular computadora rural depto_2- depto_7 hhsize ///
 migr_jefe cpropia_jefe asalariado_jefe ocupado_jefe esco_jefe married_jefe  menores_hh _deciles2- _deciles10 if eig==1

sum edad_jefe sexo_jefe tipoviv2 tipoviv3 numero_piezas techo_2-techo_5 agua_2- agua_6 v_propia celular computadora rural depto_2- depto_7 hhsize ///
 migr_jefe cpropia_jefe asalariado_jefe ocupado_jefe esco_jefe married_jefe  menores_hh _deciles2- _deciles10 if eig==0

********* Regression

// Dependent variables

global xvar edad_jefe sexo_jefe tipoviv2 tipoviv3 numero_piezas techo_2-techo_5 agua_2- agua_6 v_propia celular computadora rural depto_2- depto_7 hhsize ///
 migr_jefe cpropia_jefe asalariado_jefe ocupado_jefe esco_jefe married_jefe  menores_hh _deciles2- _deciles10

*reg kwh $xvar  if engho==1

gen eph = eig==0

* igv share

*gen igv_s=  (igv/TamHog)/ disposable_income_pc 

*drop if (igv_s >1) & eig==1

reg ratio_nafta $xvar  [aw=fex] if eig==1 

predict fitted  if eig==1 

predict theresid if eig==1  , resid

sum theresid

replace fitted= fitted 


replace theresid=exp(theresid)

sum theresid

gen y_imputed=0   if eig==0

mata : st_view(MM=., ., "y_imputed","eph")


// bootstraping samples 

forvalues ii=1/500 {

preserve 

keep if eig==1

bsample 

* qui reg lkwh $xvar  

qui reg ratio_nafta $xvar  [aw=fex]  

predict theresid_simu  , resid

*replace theresid_simu=exp(theresid_simu)

sum theresid_simu

scalar  thesd=r(sd)

mat betas=e(b)

scalar themean=r(mean)

restore 

mat score y = betas if eig==0


mata : y=st_data(., "y","eph")

if (`ii')==1 {


mata: Y_boots= y 

}

else {

mata: Y_boots= Y_boots, y 


}

drop y

}


mata:  index=imp=(ceil(500*runiform(rows(y),1)))

mata: index= J(1,500,index)

mata: c=1::500

mata: c=c'

mata: c=J(rows(y),1,c)

mata:  loc = index:==c

mata: imput=rowsum(Y_boots:*loc)

mata: MM[.,.]=imput

gen theobs=_n

preserve

mata : y_eph=st_data(., "y_imputed theobs","eph")

mata : y_engho=st_data(., "fitted theobs hhid","eig")

mata: y_eph=sort(y_eph,1)

mata: y_engho=sort(y_engho,1)

mata:  y_eph=  y_eph, J(rows(y_eph),5,0)

mata: loc_min=(J(rows(y_engho),1,y_eph[100,1]) :>= y_engho[.,1])

mata: loc_max=(J(rows(y_engho),1,y_eph[1,1]) :< y_engho[.,1])

mata: 


for (i=1; i<=rows(y_eph); i++)   {

loc_min=(J(rows(y_engho),1,y_eph[i,1]) :>= y_engho[.,1])

if (sum(loc_min)==0 | sum(loc_min)==1) {

y_eph[i,3::7]= y_engho[1::5,3]'

}


if (sum(loc_min)==2) {

y_eph[i,3::7]= y_engho[2::6,3]'

} 


if (sum(loc_min)>2 & sum(loc_min)<rows(y_engho)-1    ) {

y_eph[i,3::7]= y_engho[(sum(loc_min)-2)::(sum(loc_min)+2),3]'

}


if ( sum(loc_min)>=rows(y_engho)-1    ) {

y_eph[i,3::7]= y_engho[rows(y_engho)-4::rows(y_engho),3]'

}

}

end


mata: st_matrix("y_eph",y_eph)

clear

svmat y_eph 

rename y_eph2 theobs

keep theobs y_eph3-y_eph7

tempfile imputation

save `imputation'

restore

merge 1:1 theobs using `imputation'  , nogen

rename y_eph3 _1_v1
rename y_eph4 _2_v1
rename y_eph5 _3_v1
rename y_eph6 _4_v1
rename y_eph7 _5_v1

gen x = int(runiform(1,6))

gen     imputed_nafta_v1= _1_v1    if x==1

replace imputed_nafta_v1= _2_v1    if x==2

replace imputed_nafta_v1= _3_v1    if x==3

replace imputed_nafta_v1= _4_v1    if x==4

replace imputed_nafta_v1= _5_v1    if x==5

*sum imputed_igv_s if eig==0

keep if eig==0

keep UPM NVIVI NHOGA imputed_nafta_v1

// this is to merge with flavia datasets 

rename UPM upm
rename NVIVI nvivi
rename NHOGA nhoga

foreach var in upm nvivi nhoga {
	tostring `var', replace
	replace `var'=`var' + "X" if length(`var')==2
	replace `var'=`var' + "XX" if length(`var')==1
}
egen double famunit=concat(upm nvivi nhoga)

*save "$data\imp_igv.dta" ,replace 
tempfile imp_nafta

save `imp_nafta'





*****************************
*  SC
*****************************
** Load eig and merge  imputation variables 

*use "$data\cons_tax.dta"  , clear  

use `cons_tax'  , clear  

merge 1:1 UPM NVIVI NHOGA using `eig_toimpute'

keep if _merge==3

gen eig=1

append using  `part_II'

replace eig=0 if eig==.


// generete dummies 

ta tipo_vivienda , gen(tipoviv)

ta techo  , gen(techo_)

ta agua    , gen(agua_)

ta depto   , gen(depto_)

ta deciles , gen(_deciles)


sum edad_jefe sexo_jefe tipoviv2 tipoviv3 numero_piezas techo_2-techo_5 agua_2- agua_6 v_propia celular computadora rural depto_2- depto_7 hhsize ///
 migr_jefe cpropia_jefe asalariado_jefe ocupado_jefe esco_jefe married_jefe  menores_hh _deciles2- _deciles10 if eig==1

sum edad_jefe sexo_jefe tipoviv2 tipoviv3 numero_piezas techo_2-techo_5 agua_2- agua_6 v_propia celular computadora rural depto_2- depto_7 hhsize ///
 migr_jefe cpropia_jefe asalariado_jefe ocupado_jefe esco_jefe married_jefe  menores_hh _deciles2- _deciles10 if eig==0

********* Regression

// Dependent variables

global xvar edad_jefe sexo_jefe tipoviv2 tipoviv3 numero_piezas techo_2-techo_5 agua_2- agua_6 v_propia celular computadora rural depto_2- depto_7 hhsize ///
 migr_jefe cpropia_jefe asalariado_jefe ocupado_jefe esco_jefe married_jefe  menores_hh _deciles2- _deciles10

*reg kwh $xvar  if engho==1

gen eph = eig==0

* igv share

*gen igv_s=  (igv/TamHog)/ disposable_income_pc 

*drop if (igv_s >1) & eig==1

reg total_isc $xvar [aw=fex] if eig==1 

predict fitted  if eig==1 

predict theresid if eig==1  , resid

sum theresid

replace fitted= fitted 


replace theresid=exp(theresid)

sum theresid

gen y_imputed=0   if eig==0

mata : st_view(MM=., ., "y_imputed","eph")


// bootstraping samples 

forvalues ii=1/500 {

preserve 

keep if eig==1

bsample 

* qui reg lkwh $xvar  

qui reg total_isc $xvar [aw=fex]  

predict theresid_simu  , resid

*replace theresid_simu=exp(theresid_simu)

sum theresid_simu

scalar  thesd=r(sd)

mat betas=e(b)

scalar themean=r(mean)

restore 

mat score y = betas if eig==0


mata : y=st_data(., "y","eph")

if (`ii')==1 {


mata: Y_boots= y 

}

else {

mata: Y_boots= Y_boots, y 


}

drop y

}


mata:  index=imp=(ceil(500*runiform(rows(y),1)))

mata: index= J(1,500,index)

mata: c=1::500

mata: c=c'

mata: c=J(rows(y),1,c)

mata:  loc = index:==c

mata: imput=rowsum(Y_boots:*loc)

mata: MM[.,.]=imput

gen theobs=_n

preserve

mata : y_eph=st_data(., "y_imputed theobs","eph")

mata : y_engho=st_data(., "fitted theobs hhid","eig")

mata: y_eph=sort(y_eph,1)

mata: y_engho=sort(y_engho,1)

mata:  y_eph=  y_eph, J(rows(y_eph),5,0)

mata: loc_min=(J(rows(y_engho),1,y_eph[100,1]) :>= y_engho[.,1])

mata: loc_max=(J(rows(y_engho),1,y_eph[1,1]) :< y_engho[.,1])

mata: 


for (i=1; i<=rows(y_eph); i++)   {

loc_min=(J(rows(y_engho),1,y_eph[i,1]) :>= y_engho[.,1])

if (sum(loc_min)==0 | sum(loc_min)==1) {

y_eph[i,3::7]= y_engho[1::5,3]'

}


if (sum(loc_min)==2) {

y_eph[i,3::7]= y_engho[2::6,3]'

} 


if (sum(loc_min)>2 & sum(loc_min)<rows(y_engho)-1    ) {

y_eph[i,3::7]= y_engho[(sum(loc_min)-2)::(sum(loc_min)+2),3]'

}


if ( sum(loc_min)>=rows(y_engho)-1    ) {

y_eph[i,3::7]= y_engho[rows(y_engho)-4::rows(y_engho),3]'

}

}

end


mata: st_matrix("y_eph",y_eph)

clear

svmat y_eph 

rename y_eph2 theobs

keep theobs y_eph3-y_eph7

tempfile imputation

save `imputation'

restore

merge 1:1 theobs using `imputation'  , nogen

rename y_eph3 _1_v1
rename y_eph4 _2_v1
rename y_eph5 _3_v1
rename y_eph6 _4_v1
rename y_eph7 _5_v1

gen x = int(runiform(1,6))

gen     imputed_isc_v1= _1_v1    if x==1

replace imputed_isc_v1= _2_v1    if x==2

replace imputed_isc_v1= _3_v1    if x==3

replace imputed_isc_v1= _4_v1    if x==4

replace imputed_isc_v1= _5_v1    if x==5

*sum imputed_igv_s if eig==0

keep if eig==0

keep UPM NVIVI NHOGA imputed_isc_v1

// this is to merge with flavia datasets 

rename UPM upm
rename NVIVI nvivi
rename NHOGA nhoga

foreach var in upm nvivi nhoga {
	tostring `var', replace
	replace `var'=`var' + "X" if length(`var')==2
	replace `var'=`var' + "XX" if length(`var')==1
}
egen double famunit=concat(upm nvivi nhoga)

*save "$data\imp_igv.dta" ,replace 
tempfile imp_isc

save `imp_isc'






*****************************
*  IGV 
*****************************
** Load eig and merge  imputation variables 

*use "$data\cons_tax.dta"  , clear  

use `cons_tax'  , clear  

merge 1:1 UPM NVIVI NHOGA using `eig_toimpute'

keep if _merge==3

gen eig=1

append using  `part_II'

replace eig=0 if eig==.


// generete dummies 

ta tipo_vivienda , gen(tipoviv)

ta techo  , gen(techo_)

ta agua    , gen(agua_)

ta depto   , gen(depto_)

ta deciles , gen(_deciles)


sum edad_jefe sexo_jefe tipoviv2 tipoviv3 numero_piezas techo_2-techo_5 agua_2- agua_6 v_propia celular computadora rural depto_2- depto_7 hhsize ///
 migr_jefe cpropia_jefe asalariado_jefe ocupado_jefe esco_jefe married_jefe  menores_hh _deciles2- _deciles10 if eig==1

sum edad_jefe sexo_jefe tipoviv2 tipoviv3 numero_piezas techo_2-techo_5 agua_2- agua_6 v_propia celular computadora rural depto_2- depto_7 hhsize ///
 migr_jefe cpropia_jefe asalariado_jefe ocupado_jefe esco_jefe married_jefe  menores_hh _deciles2- _deciles10 if eig==0

********* Regression

// Dependent variables

global xvar edad_jefe sexo_jefe tipoviv2 tipoviv3 numero_piezas techo_2-techo_5 agua_2- agua_6 v_propia celular computadora rural depto_2- depto_7 hhsize ///
 migr_jefe cpropia_jefe asalariado_jefe ocupado_jefe esco_jefe married_jefe  menores_hh _deciles2- _deciles10

*reg kwh $xvar  if engho==1

gen eph = eig==0

* igv share

*gen igv_s=  (igv/TamHog)/ disposable_income_pc 

*drop if (igv_s >1) & eig==1

reg total_iva $xvar [aw=fex] if eig==1 

predict fitted  if eig==1 

predict theresid if eig==1  , resid

sum theresid

replace fitted= fitted 


replace theresid=exp(theresid)

sum theresid

gen y_imputed=0   if eig==0

mata : st_view(MM=., ., "y_imputed","eph")


// bootstraping samples 

forvalues ii=1/500 {

preserve 

keep if eig==1

bsample 

* qui reg lkwh $xvar  

qui reg total_iva $xvar [aw=fex]  

predict theresid_simu  , resid

*replace theresid_simu=exp(theresid_simu)

sum theresid_simu

scalar  thesd=r(sd)

mat betas=e(b)

scalar themean=r(mean)

restore 

mat score y = betas if eig==0


mata : y=st_data(., "y","eph")

if (`ii')==1 {


mata: Y_boots= y 

}

else {

mata: Y_boots= Y_boots, y 


}

drop y

}


mata:  index=imp=(ceil(500*runiform(rows(y),1)))

mata: index= J(1,500,index)

mata: c=1::500

mata: c=c'

mata: c=J(rows(y),1,c)

mata:  loc = index:==c

mata: imput=rowsum(Y_boots:*loc)

mata: MM[.,.]=imput

gen theobs=_n

preserve

mata : y_eph=st_data(., "y_imputed theobs","eph")

mata : y_engho=st_data(., "fitted theobs hhid","eig")

mata: y_eph=sort(y_eph,1)

mata: y_engho=sort(y_engho,1)

mata:  y_eph=  y_eph, J(rows(y_eph),5,0)

mata: loc_min=(J(rows(y_engho),1,y_eph[100,1]) :>= y_engho[.,1])

mata: loc_max=(J(rows(y_engho),1,y_eph[1,1]) :< y_engho[.,1])

mata: 


for (i=1; i<=rows(y_eph); i++)   {

loc_min=(J(rows(y_engho),1,y_eph[i,1]) :>= y_engho[.,1])

if (sum(loc_min)==0 | sum(loc_min)==1) {

y_eph[i,3::7]= y_engho[1::5,3]'

}


if (sum(loc_min)==2) {

y_eph[i,3::7]= y_engho[2::6,3]'

} 


if (sum(loc_min)>2 & sum(loc_min)<rows(y_engho)-1    ) {

y_eph[i,3::7]= y_engho[(sum(loc_min)-2)::(sum(loc_min)+2),3]'

}


if ( sum(loc_min)>=rows(y_engho)-1    ) {

y_eph[i,3::7]= y_engho[rows(y_engho)-4::rows(y_engho),3]'

}

}

end


mata: st_matrix("y_eph",y_eph)

clear

svmat y_eph 

rename y_eph2 theobs

keep theobs y_eph3-y_eph7

tempfile imputation

save `imputation'

restore

merge 1:1 theobs using `imputation'  , nogen

rename y_eph3 _1_v1
rename y_eph4 _2_v1
rename y_eph5 _3_v1
rename y_eph6 _4_v1
rename y_eph7 _5_v1

gen x = int(runiform(1,6))

gen     imputed_vat_v1= _1_v1    if x==1

replace imputed_vat_v1= _2_v1    if x==2

replace imputed_vat_v1= _3_v1    if x==3

replace imputed_vat_v1= _4_v1    if x==4

replace imputed_vat_v1= _5_v1    if x==5

*sum imputed_igv_s if eig==0

keep if eig==0

keep UPM NVIVI NHOGA imputed_vat_v1

// this is to merge with flavia datasets 

rename UPM upm
rename NVIVI nvivi
rename NHOGA nhoga

foreach var in upm nvivi nhoga {
	tostring `var', replace
	replace `var'=`var' + "X" if length(`var')==2
	replace `var'=`var' + "XX" if length(`var')==1
}
egen double famunit=concat(upm nvivi nhoga)

*save "$data\imp_igv.dta" ,replace 
tempfile imp_vat

save `imp_vat'

