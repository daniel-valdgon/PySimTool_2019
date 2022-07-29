*! version 0.1 Nov 22-2019
*! Paul Corral - pcorralrodas@worldbank.org  
*! Jia Gao - World Bank, jgao4@worldbank.org
*! Equity policy lab

cap program drop dmatch
program define dmatch, eclass byable(recall)
	version 13, missing
#delimit;
	syntax varlist(min=2 numeric fv) [if] [in],
	uniqid(varlist)
	todata(varlist max=1 numeric) 
	[
		seed(integer 12345)
		strata(varlist max=1 numeric)
		trimup(numlist integer >=90 <=99)
		trimlow(numlist integer >0 <=10)
		trimvar(varlist max=1 numeric)
	];
#delimit cr
set more off

qui{
	*===============================================================================
	// 1. HOUSE KEEPING
	*===============================================================================
	//mark sample for use
	marksample touse
	if ("`strata'"!="") replace `touse' = 0 if missing(`strata')
	
	//Ensure to data is dummy
	levelsof `todata', local(ch1)
	local ch1: list sort ch1
	tokenize `ch1'
	if (`1'!=0 & `2'!=1){
		dis as error "Variable to identify target data given in option todata must be binary"
		error 198
		exit
	}
	
	//Check unique id
	isid `todata' `uniqid' 
	sort `todata' `strata' `uniqid'
	
	//Get matching vector names:
	tokenize `varlist'
	local depvar `1'
	macro shift
	local therest `*'
	
	//mark vector for target data
	tempvar touse2
	
	if ("`strata'"!="")		gen `touse2' = !missing(`depvar') & `todata'==1 & !missing(`strata')
	else                    gen `touse2' = !missing(`depvar') & `todata'==1
	
	//Check trimming values
	if ("`trimup'"!=""){
		if (!inrange(`trimup',90,99)){
			dis as error "Upper trim values must be between p90 and p99"
			error 198
			exit
		}
	}
	if ("`trimlow'"!=""){
		if (!inrange(`trimlow',1,10)){
			dis as error "Lower trim values must be between p01 and p10"
			error 198
			exit
		}
	}
	
	//Set seed
	set seed `seed'
	
	//check Strata
	if ("`strata'"!="") {
		levelsof `strata' if `touse' 	== 1, local (str1)
		levelsof `strata' if `touse2'	== 1, local (str2)
		local str: list str1 === str2
		if (`str' == 0) {
			dis as error "Strata in source and target data do not match, please check"
			error 198
			tab `strata' `todata'
			exit
		}
	
	}
*===============================================================================
//2. Proc data
*===============================================================================	
	//Trimming of outliers
	if ("`trimup'"!=""|"`trimlow'"!=""){
		if ("`trimvar'"==""){
			sum `depvar' if `touse',d
			local trimi `depvar'
		}
		else{
			sum `trimvar' if `touse',d
			local trimi `trimvar'
		}
	}
	if ("`trimup'"!=""){
		if (r(p`trimup')==.){
			dis as error "You have too few observations for trimming level selected"
			error 198
			exit
		}
		replace `touse' = 0 if `trimi'>=r(p`trimup') 
	}
	if ("`trimlow'"!=""){
		local tlow = length("`trimlow'")
		if (`tlow'==1){
			if (r(p0`trimup')==.){
				dis as error "You have too few observations for trimming level selected"
				error 198
				exit
			}
			replace `touse' = 0 if `trimi'<=r(p0`trimlow')			
		}
		else{
			if (r(p`trimup')==.){
				dis as error "You have too few observations for trimming level selected"
				error 198
				exit
			}
			replace `touse' = 0 if `trimi'<=r(p`trimlow') 
		}
	}
	
	//Bring in target data matching vector
	replace `depvar' = `depvar' + runiform()/1000
	if ("`strata'"==""){
		
		
		mata: st_view(Ytarget=.,.,"`depvar'","`touse2'")
		mata: st_view(Ysource=.,.,"`depvar' `therest'","`touse'")
		mata: tn = cols(Ysource)
		mata: st_store(.,st_varindex(tokens("`therest'")),"`touse2'", (_randomleo(Ysource,Ytarget))[|.,2 \ .,tn|])
	}
	else{
		
		tempvar u1 u2			
		foreach i of local str1 {
			gen `u1' = `touse' 	& `strata' == `i'
			gen `u2' = `touse2' & `strata' == `i'			
			mata: st_view(Ytarget=.,.,"`depvar'","`u2'")
			mata: st_view(Ysource=.,.,"`depvar' `therest'","`u1'")
			mata: tn = cols(Ysource)
			mata: st_store(.,st_varindex(tokens("`therest'")),"`u2'", (_randomleo(Ysource,Ytarget))[|.,2 \ .,tn|])
			drop `u1' `u2'
		}
		
	}
 
	
}
end
mata
	function _randomleo(yo, yh2){
		ry = rows(yh2)
		totcol = (cols(yo)+1)		
		//random sample of y
		tosort     = sort((runningsum(J(ry,1,1)),yh2),2)
		tosort2 = sort(_f_sampleepsi22(1, ry, yo),1)
		tosort2 = sort((tosort[.,1],tosort2),1)
		cols(tosort2)
		return(tosort2[.,2..totcol])

		
	}	

	function _f_sampleepsi22(real scalar n, real scalar dim, real matrix eps){
		N = rows(eps)
        sige2=eps[ceil(N*runiform(dim,1)),.]
		return(sige2)	
	}

end	
