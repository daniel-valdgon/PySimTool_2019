

use "$data_pry\indiv_level_ref.dta" , clear

rename taxable_income_irp taxable_income_irp_ref

rename  fex fex_ref

rename irp  irp_ref

rename  tot_pit tot_pit_ref

rename labor_tax  labor_tax_ref

rename dividendo_tax dividendo_tax_ref 

rename alquiler_tax  alquiler_tax_ref

rename deductible_irp deductible_irp_ref 

rename deductible_iva deductible_iva_ref

rename t_lab_inc t_lab_inc_ref

rename tot_deduction_taken  tot_deduction_taken_ref 

rename e01aimde e01aimde_ref 

rename iva_inc iva_inc_ref 

rename pre_deduction pre_deduction_ref

rename _mylab_inc _mylab_inc_ref

keep famunit l02 taxable_income_irp_ref  fex_ref tot_pit_ref deductible_irp_ref deductible_iva_ref irp_ref  labor_tax_ref  dividendo_tax_ref  alquiler_tax_ref t_lab_inc_ref tot_deduction_taken_ref e01aimde_ref iva_inc_ref pre_deduction_ref _mylab_inc_ref

drop if l02==.

gen sim=0

tempfile aux
save `aux'

use "$data_pry\indiv_level_sim.dta" , clear

gen sim=1 

drop _merge 

merge 1:1 famunit l02  using `aux' 

sum taxable_income_irp [iw=fex]

sum taxable_income_irp_ref [iw=fex_ref]



sum tot_pit [iw=fex*12]

sum tot_pit_ref [iw=fex_ref*12]

sort tot_pit


br  _mylab_inc_ref _mylab_inc  if famunit=="2818917X1XX"

br  taxable_income_irp_ref taxable_income_irp



