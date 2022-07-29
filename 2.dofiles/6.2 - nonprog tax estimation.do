
*===============================================================================
	
	//If the tax brackets are determined BEFORE applying deductions
	gen double labor_tax=0
	replace labor_tax = t_lab_inc *trate if ~missing(trate)
	gen double net_lab_inc = t_lab_inc - labor_tax if ~missing(labor_tax)	

	lab var labor_tax "Labor tax"
	lab var net_lab_inc "Labor income net of direct taxes"
