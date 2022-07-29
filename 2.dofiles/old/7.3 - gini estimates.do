

//Macros
local gini_1 $gini_1
local gini_2 $gini_2
local gini_3 $gini_3
local gwth2020 = -3.5
local gwth2021 = 3.2
local gwth2022 = 2.9

 if ($simyear== 2020){

*use "$datagini\indiv_2020.dta", clear 

use `indiv_2020'  , clear

* Obtaining the coordinates for the Lorenz curve 

sort ipcm
ssc install glcurve
qui glcurve ipcm [aw=fex] , pvar(p) glvar(lor_coor) lorenz replace

* Ploting lorenz

line lor_coor p, sort

/** Now, this is the key. We are assuming that incomes distribute log-normal.
 If this is true, then the Lorenz of a log-normal distribution has the following funtional form: 
L = F ( F^-1(p)  - sig), where F is the CDF of a standard normal distribution and F^-1 is the inverse of the CDF
Sig is the standard deviation and this will be the only factor that affects inequality (and the lorenz curve) 
*/


* Estimating this by NLS (we need to avoid "1" for continuity) 
nl (lor_coor = normal(invnormal(p)-{sig})) if p<1

* To explore how this function approaches the empirical distribution (actual) we can do 
predict lor_norm
line lor_norm lor_coor p, sort

*The gini can be estimated by 
global gini_normal=2*normal( _b[/sig]/ sqrt(2))-1
global sig0 = _b[/sig]
display $gini_normal

* Comparing with the current gini 

//ssc install fastgini
fastgini ipcm

* Now lets say we want to get to a gini that is 0.5 (Target Gini). Then we calculate the sigma that repplicates this. 
//global gini_target = 0.5
global sig1= invnormal( (`gini_1' + 1) * 0.5) * sqrt(2)
display $sig1

* Now we do the simulation 
gen lor_hat0 = normal(invnormal(p)- $sig0 )
gen lor_hat1 = normal(invnormal(p)- $sig1 )

* We obtain the derivatives:
dydx lor_hat0 p, gen(dl0_dp)
dydx lor_hat1 p, gen(dl1_dp)

* Lets now simulate the incomes
* First lets play with the original incomes. 

sum ipcm
global mn_ipcm2 = r(mean)
gen yh0_norm = dl0_dp * $mn_ipcm2
qui two kdensity yh0_norm if p<0.995 || kdensity ipcm if p<0.995

* Now, lets put the growth in play. Consider that this is not a growth for everyone but across the distribution adjusted. Assume a growth of 5% 

gen yh1_norm = dl1_dp * (1+(`gwth2020'/100)) * $mn_ipcm2


* Based on this we can calculate the growth on income for each person. Remember that not everyones income growths at the same rate.  

gen g_norm=yh1_norm /yh0_norm -1
scatter g_norm p

*graph export "growth2020.png", replace
*putexcel set "$xls_pry", sheet("Income growth 19-20") modify

*putexcel (F8)=image("growth2020.png")
}


 if ($simyear== 2021){

*use "$datagini\indiv_2021.dta", clear 

use `indiv_2021'  , clear

* Obtaining the coordinates for the Lorenz curve 

sort ipcm
ssc install glcurve
glcurve ipcm [aw=fex] , pvar(p) glvar(lor_coor) lorenz replace

* Ploting lorenz

line lor_coor p, sort

/** Now, this is the key. We are assuming that incomes distribute log-normal.
 If this is true, then the Lorenz of a log-normal distribution has the following funtional form: 
L = F ( F^-1(p)  - sig), where F is the CDF of a standard normal distribution and F^-1 is the inverse of the CDF
Sig is the standard deviation and this will be the only factor that affects inequality (and the lorenz curve) 
*/


* Estimating this by NLS (we need to avoid "1" for continuity) 
nl (lor_coor = normal(invnormal(p)-{sig})) if p<1

* To explore how this function approaches the empirical distribution (actual) we can do 
predict lor_norm
qui line lor_norm lor_coor p, sort

*The gini can be estimated by 
global gini_normal=2*normal( _b[/sig]/ sqrt(2))-1
global sig0 = _b[/sig]
display $gini_normal

* Comparing with the current gini 

//ssc install fastgini
fastgini ipcm

* Now lets say we want to get to a gini that is 0.5 (Target Gini). Then we calculate the sigma that repplicates this. 
//global gini_target = 0.5
global sig1= invnormal( (`gini_2' + 1) * 0.5) * sqrt(2)
display $sig1

* Now we do the simulation 
gen lor_hat0 = normal(invnormal(p)- $sig0 )
gen lor_hat1 = normal(invnormal(p)- $sig1 )

* We obtain the derivatives:
dydx lor_hat0 p, gen(dl0_dp)
dydx lor_hat1 p, gen(dl1_dp)

* Lets now simulate the incomes
* First lets play with the original incomes. 

sum ipcm
global mn_ipcm2 = r(mean)
gen yh0_norm = dl0_dp * $mn_ipcm2
qui two kdensity yh0_norm if p<0.995 || kdensity ipcm if p<0.995

* Now, lets put the growth in play. Consider that this is not a growth for everyone but across the distribution adjusted. Assume a growth of 5% 

gen yh1_norm = dl1_dp * (1+(`gwth2021'/100)) * $mn_ipcm2


* Based on this we can calculate the growth on income for each person. Remember that not everyones income growths at the same rate.  

gen g_norm=yh1_norm /yh0_norm -1
scatter g_norm p

*graph export "growth2021.png", replace
*putexcel set "$xls_pry", sheet("Income growth 20-21") modify

*putexcel (F8)=image("growth2021.png")
}


 if ($simyear== 2022){

*use "$datagini\indiv_2022.dta", clear 

use `indiv_2022'  , clear

* Obtaining the coordinates for the Lorenz curve 

sort ipcm
ssc install glcurve
qui glcurve ipcm [aw=fex] , pvar(p) glvar(lor_coor) lorenz replace

* Ploting lorenz

qui line lor_coor p, sort

/** Now, this is the key. We are assuming that incomes distribute log-normal.
 If this is true, then the Lorenz of a log-normal distribution has the following funtional form: 
L = F ( F^-1(p)  - sig), where F is the CDF of a standard normal distribution and F^-1 is the inverse of the CDF
Sig is the standard deviation and this will be the only factor that affects inequality (and the lorenz curve) 
*/


* Estimating this by NLS (we need to avoid "1" for continuity) 
nl (lor_coor = normal(invnormal(p)-{sig})) if p<1

* To explore how this function approaches the empirical distribution (actual) we can do 
predict lor_norm
qui line lor_norm lor_coor p, sort

*The gini can be estimated by 
global gini_normal=2*normal( _b[/sig]/ sqrt(2))-1
global sig0 = _b[/sig]
display $gini_normal

* Comparing with the current gini 

//ssc install fastgini
fastgini ipcm

* Now lets say we want to get to a gini that is 0.5 (Target Gini). Then we calculate the sigma that repplicates this. 
//global gini_target = 0.5
global sig1= invnormal( (`gini_3' + 1) * 0.5) * sqrt(2)
display $sig1

* Now we do the simulation 
gen lor_hat0 = normal(invnormal(p)- $sig0 )
gen lor_hat1 = normal(invnormal(p)- $sig1 )

* We obtain the derivatives:
dydx lor_hat0 p, gen(dl0_dp)
dydx lor_hat1 p, gen(dl1_dp)

* Lets now simulate the incomes
* First lets play with the original incomes. 

sum ipcm
global mn_ipcm2 = r(mean)
gen yh0_norm = dl0_dp * $mn_ipcm2
two kdensity yh0_norm if p<0.995 || kdensity ipcm if p<0.995

* Now, lets put the growth in play. Consider that this is not a growth for everyone but across the distribution adjusted. Assume a growth of 5% 

gen yh1_norm = dl1_dp * (1+(`gwth2022'/100)) * $mn_ipcm2


* Based on this we can calculate the growth on income for each person. Remember that not everyones income growths at the same rate.  

gen g_norm=yh1_norm /yh0_norm -1
scatter g_norm p

graph export "growth2022.png", replace
*putexcel set "$xls_pry", sheet("Income growth 21-22") modify

*putexcel (F8)=image("growth2022.png")
}
