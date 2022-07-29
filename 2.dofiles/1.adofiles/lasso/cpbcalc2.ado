*! cpbcalc v2 ... adjusted weight option to accept expressions
* Paul Corral - World Bank Group 
* Jose Montes - World Bank Group 
* Joao Pedro Azevedo - World Bank Group 

cap prog drop cpbcalc2
program define cpbcalc2, rclass
	version 11.2
	syntax varlist(max=1 numeric) [if] [in] [aw pw fw] , [ gini theil poverty(numlist >=0 max=1 integer) line(numlist >0 max=1)]
	
marksample touse1					 
local vlist: list uniq varlist

//Get weights matrix
mata:st_view(y=., .,"`vlist'","`touse1'")

//Weights
	if "`exp'"=="" {
		tempvar w
		qui:gen `w' = 1
	}
	else{
		tempvar w 
		qui:gen double `w' `exp'
	}
	mata: st_view(w=., .,"`w'","`touse1'")
	
if ("`poverty'"!=""){
	if ("`line'"==""){
		dis as error "You need to specify a threshold for poverty calculation"
		exit
	}
}

if ("`line'"!=""){
	if ("`poverty'"==""){
		dis as error "You specified a poverty line, but no FGT value"
		exit
	}
}




local options gini theil poverty

foreach x of local options{
	if ("``x''"!=""){
		if ("`x'"=="poverty"){
			mata:p=_CPBfgt(y,w,`line',``x'')	
			mata: st_local("_x0",strofreal(p))
			return local fgt``x'' = `_x0'
			
			dis in green "fgt``x'' : `_x0'"
		}
		else{
			mata:p=_CPB`x'(y,w)
			mata: st_local("_x0",strofreal(p))
			return local `x' = `_x0'
			
			dis in green "`x' : `_x0'"
		}	
	}
}	

	
end
	
mata
function _CPBtheil(y,w){
	one=ln(y:/mean(y,w))
	two=one:*(y:/mean(y,w))
	return(mean(two,w))
}

	function _CPBtheils(x,w){
		
		for(i=1;i<=cols(x);i++){
			if (i==1) out = _CPBtheil(x[.,i],w)
			else      out = out,_CPBtheil(x[.,i],w)
		}
	return(out)
	}

function _CPBgini(x, w) {
	t = x,w
	_sort(t,1)
	x=t[.,1]
	w=t[.,2]
	xw = x:*w
	rxw = quadrunningsum(xw) :- (xw:/2)
	return(1- 2*((quadcross(rxw,w)/quadcross(x,w))/quadcolsum(w)))
}

	function _CPBginis(x,w){
		
		for(i=1;i<=cols(x);i++){
			if (i==1) out = _CPBgini(x[.,i],w)
			else      out = out,_CPBgini(x[.,i],w)
		}
	return(out)
	}
	
	function _CPBfgt(x,w,z,a){
		return(mean((x:<z):*(1:-(x:/z)):^(a),w))
	}
	
	function _CPBfgts(x,w,z,a){
		
		for(i=1;i<=cols(x);i++){
			if (i==1) out = _CPBfgt(x[.,i],w,z,a)
			else      out = out,_CPBfgt(x[.,i],w,z,a)
		}
	return(out)
	}

end


