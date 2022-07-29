

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







//POVERTY RATE IN 2020 WITH COVID-19 AND  MITIGATION MEASURES
 if ($simyear== 2019){

gen monto_pyty1_pc= 0
gen monto_pyty2_pc= 0
gen monto_nangareko_pc= 0

}

 if ($simyear== 2020){

 
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
*gen hh_covid_transf = x/totpers   //  JP: mistake here
gen hh_covid_transf = x
drop x

* Generating household incomes

egen hh_pytyvo1=sum(pytyvo1), by(famunit)
egen hh_pytyvo2=sum(pytyvo2), by(famunit)

egen double income_comp_hh = rsum( hh_pytyvo1 hh_pytyvo2 hh_covid_transf)

gen double income_comp_pc = income_comp_hh/totpers

gen monto_pyty1_pc= hh_pytyvo1/totpers
gen monto_pyty2_pc= hh_pytyvo2/totpers
gen monto_nangareko_pc= hh_covid_transf/totpers


}

if ($simyear== 2021) {


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
*gen hh_covid_transf = x/totpers   //  JP: mistake here
gen hh_covid_transf = x
drop x

* Generating household incomes

egen hh_pytyvo1=sum(pytyvo1), by(famunit)
egen hh_pytyvo2=sum(pytyvo2), by(famunit)



egen double income_comp_hh = rsum( hh_pytyvo1 hh_pytyvo2 hh_covid_transf)

gen double income_comp_pc = income_comp_hh/totpers

gen monto_pyty1_pc= hh_pytyvo1/totpers
gen monto_pyty2_pc= hh_pytyvo2/totpers
gen monto_nangareko_pc= hh_covid_transf/totpers



}


if ($simyear== 2022) {

gen adj2022 = (1+(0.029)*0.7)


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
gen hh_covid_transf = x
drop x

* Generating household incomes

egen hh_pytyvo1=sum(pytyvo1), by(famunit)
egen hh_pytyvo2=sum(pytyvo2), by(famunit)

egen double income_comp_hh = rsum( hh_pytyvo1 hh_pytyvo2 hh_covid_transf)

gen double income_comp_pc = income_comp_hh/totpers


gen monto_pyty1_pc= hh_pytyvo1/totpers
gen monto_pyty2_pc= hh_pytyvo2/totpers
gen monto_nangareko_pc= hh_covid_transf/totpers


}



