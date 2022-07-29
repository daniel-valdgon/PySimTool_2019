

use "C:\Users\wb547455\WBG\Flavia Giannina Sacco Capurro - 5. PySim 2019\data_prep_indtaxes.dta"  , clear


// gasto_compra gasto_nocompra gasto_total

collapse (sum) gasto_compra gasto_nocompra gasto_total gasto_alimentos (max)    ipcm total_miembros fex , by(famunit)

gen fex_pop= fex*total_miembros

// ingreso agropecuario 

merge 1:1 famunit using "C:\Users\wb547455\WBG\Luis Bernardo Recalde Ramirez - 01 - PySimTool\PySimTool_2019\1.Data\eig_toimpute.dta" , keepusing(agro_income agro_income_hh)  nogen



// ventiles 

_ebin ipcm  [aw=fex_pop], nq(20) gen(ventiles_pc)    // it is similar to the xtile 


// gasto_mon gasnomon alimentos

gen consumo=gasto_total

//share alimentos 

gen share_alimentos= gasto_alimentos/ gasto_compra

table ventiles_pc [aw=fex_pop] , c(mean share_alimentos)


// share income 

gen share_alim_inc= gasto_alimentos / (ipcm*total_miembros)

table ventiles_pc [aw=fex_pop] , c(mean share_alim_inc)

// income consumption ratio 

gen share_inco_cons=  (ipcm*total_miembros)/ gasto_total

table ventiles_pc [aw=fex_pop] , c(mean share_alimentos mean share_alim_inc  mean share_inco_cons)

// food income and expenses 

gen aux_profit=  agro_income_hh - gasto_alimentos

gen food_income_expenses=   aux_profit>0

table ventiles_pc [aw=fex_pop]   , c(mean food_income_expenses) 

table ventiles_pc [aw=fex_pop]  if agro_income_hh>0 , c(mean food_income_expenses) 






// counting hh's

gen all=1

table ventiles_pc   , c(sum all)


// income descriptives 


table ventiles_pc [iw=fex_pop]  , c(min  ipcm max  ipcm mean  ipcm )



