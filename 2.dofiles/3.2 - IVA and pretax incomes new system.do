*===============================================================================
// MACROS
*===============================================================================
local _min_imp=$min_imp 
//Monthly
local _min_imp = `_min_imp'/12

local _vat $VAT


*===============================================================================
//Income classification locals
#delimit;

//Labor incomes - individual level - as reported in survey;
local labor_incs 
e01aimde 
e01bimde 
e01cimde;

//Pension and retirement incomes;
local pension_inc
e01hde
e01jde; 

//Capital incomes;
local alquiler 
e01dde; 
local dividendo 
e01ede;
local capital_incs `alquiler' `dividendo';

//Other market incomes from agro;
local agro 
e01mde; 

// All other market incomes;
local other_mkt_incs `alquiler' `dividendo' `agro'; 

//Non categorized market income;
local jefe_incs
e01kjde;

//Imputed rents;
local imp_rent
v19ede;

// Private transfers;
local private_transfers 
e01fde
e02l1bde
e02l2bde
;

//Other transfer incomes: e01ide(Tekopora), e01gde(divorcio o cuidado de hijos) e01kde(AM) e01lde(viveres de otras instituciones pub);
local transfers
e01ide
e01gde
e01kde
e01lde;


//These are labor income in NET of SSC (changed in SSC.do);
local mis_ing_lab //In new system, labor incomes are divided between 'asalariados/cuenta propia (labor)' & 'empleadores (unidad productiva)' 
e01aimdeb2_lab 
e01bimdeb2_lab 
e01cimde_lab;

local mis_ing_uprod //These variables are created within this dofile
e01aimdeb2_uprod 
e01bimdeb2_uprod 
e01cimde_uprod;


#delimit cr

*===============================================================================
// IVA deductions...
*===============================================================================
		
	gen double deductible_irp=ipcm*med_prop_gasto_formal*totpers*12	
	gen double deductible_iva=ipcm*med_prop_gasto_trabajo*totpers*12
		label var deductible_irp "Expenses deductible from IRP - formal expenses - hh level"
		label var deductible_iva "Expenses deductible of IVA - work expenses - hh level"
	
	replace deductible_irp=0
	replace deductible_iva=0
	
	rename grava_irp1 g_e01aimdeb2
	rename grava_irp2 g_e01bimdeb2
	rename grava_irp3 g_e01cimde
	
	rename grava_iva1 i_e01aimdeb2
	rename grava_iva2 i_e01bimdeb2
	//gen i_e01cimde = 0

//gen hhpayIVA=0
	
	gen double iva_inc = 0
	replace iva_inc = e01aimdeb2*(1/(1+(`_vat'/100)))*(i_e01aimdeb2==1) + iva_inc if ~missing(e01aimdeb2)
	replace iva_inc = e01bimdeb2*(1/(1+(`_vat'/100)))*(i_e01bimdeb2==1) + iva_inc if ~missing(e01bimdeb2)
		lab var iva_inc "Taxable income net of IVA deduction (if subject to IVA)"

	egen double share_iva = sum((!missing(iva_inc) & iva_inc!=0)/totpers), by(famunit)
		lab var share_iva "Share of HH members who pay IVA salario"
	gen hhpayIVA = share_iva!=0
		lab var hhpayIVA "Household has a member that pays IVA salario"
	gen paga_iva = !missing(iva_inc) & iva_inc!=0
		lab var paga_iva "Individual pays IVA salario"	
	
//gross labor income net of IVA tax
	//replace e01aimdeb2 = iva_inc if ~missing(iva_inc) & iva_inc!=0
	//replace e01bimdeb2 = iva_inc if ~missing(iva_inc) & iva_inc!=0

	
*===============================================================================
// Get pretaxable income
*===============================================================================

* Ingreso laboral - asalariado o cuenta propia
* A1. Identifies contributors to IRP...

	* Grava por ingreso Principal: asalariados (publicos y privados en establecimiento con emision de factura) y cuentapropistas (con emision de factura o que tienen RUC y que no son sociedad)
	*gen gravairp_lab1=(b12==1 | (b12==2 & (b28==1 | b10==1)) | (b12==4 & cod_ocuirp1==1 & (b29!=2 | b29!=3 | b29!=4) & (b30==1 | b28==1)) )

	gen gravairp_lab1=(gravairp_emppub1==1 | gravairp_emppriv1==1 | gravairp_cuentprop1==1) 
	la var gravairp_lab1 "Grava IRP por ingreso laboral primario"

	* Grava por ingreso secundario : asalariados (publicos y privados en establecimiento con emision de factura) y cuentapropistas (con emision de factura o que tienen RUC y que no son sociedad)
	*gen gravairp_lab2=(c09==1 | (c09==2 & (c14a==1 | c07==1)) | (c09==4 & cod_ocuirp2==1 & (c14b!=2 | c14b!=3 | c14b!=4) & (c14c==1 | c14a==1)) )

	gen gravairp_lab2=(gravairp_emppub2==1 | gravairp_emppriv2==1 | gravairp_cuentprop2==1)
	la var gravairp_lab2 "Grava IRP por ingreso laboral secundario"

	* Grava por ingreso terciario: asalariados (publicos) 
	*gen gravairp_lab3=(c19==1)

	gen gravairp_lab3=(gravairp_emppub3==1)
	la var gravairp_lab3 "Grava IRP por ingreso laboral terciario"

	* Grava por ingreso principal, secundario, o terciario
	
	gen gravairp_lab=(gravairp_lab1==1| gravairp_lab2==1 | gravairp_lab3==1)
    la var gravairp_lab "Grava IRP por ingreso laboral primario, secundario y terciario"
	
* A2. Calcula ingresos que gravan

	* Variable de ingreso laboral primario para personas que gravan IRP
	* A ingreso por cuentra propia se le aplica la renta presunta segun ley
	gen e01aimdeb2_lab = 0
	replace e01aimdeb2_lab = e01aimdeb2 if gravairp_lab1==1
	replace e01aimdeb2_lab = e01aimdeb2_lab * (1-$deduct2/100) if gravairp_cuentprop1==1

	* Variable de ingreso laboral secundario para personas que gravan IRP 
	gen e01bimdeb2_lab = 0
	replace e01bimdeb2_lab = e01bimdeb2 if gravairp_lab2==1
	replace e01bimdeb2_lab = e01bimdeb2_lab * (1-$deduct2/100) if gravairp_cuentprop2==1

	* Variable de ingreso terciario para personas que gravan IRP
	gen e01cimde_lab = 0
	replace e01cimde_lab = e01cimde if gravairp_lab3==1

	*Total ingreso laboral para los que cumplen con criterios de formalidad
	egen double t_lab_inc=rsum(e01aimdeb2_lab e01bimdeb2_lab e01cimde_lab)
	
	replace t_lab_inc = t_lab_inc + iva_inc if ~missing(iva_inc)  //added this FS
	

	gen nopaga = (t_lab_inc<=`_min_imp') //Indicador de individuos que no pagan

		lab var e01aimdeb2_lab "Taxable income from primary occupation net of SSC - employed or cta ppia"
		lab var e01bimdeb2_lab "Taxable income from secondary occupation net of SSC - employed or cta ppia"
		lab var e01cimde_lab   "Taxable income from terciary occupation net of SSC - employed or cta ppia"
		lab var t_lab_inc "Taxable labor income - only employees or cta ppia if new system"
		lab var nopaga "Labor income below minimum taxable income - new system"

* B. Ingreso de por unidad productiva
* B1. Grava irp por ingreso de unidad productiva: si cumplen con requisito de formalidad 

	* Grava por ingreso primario: empleadores que tienen RUC o emiten factura legal y no son sociedad y que estan empleados en una activadad gravada por IRP
	*gen gravairp_uprod1=(b12==3 & cod_ocuirp1==1 & (b29!=2 | b29!=3 | b29!=4) & (b28==1 | b30==1))

	gen gravairp_uprod1=(gravairp_empleador1==1)

	* Grava por ingreso secundario: empleadores que tienen RUC o emiten factura legal y no son sociedad
	*gen gravairp_uprod2=(c09==3 & cod_ocuirp2==1 & (c14b!=2 | c14b!=3 | c14b!=4) & (c14a==1 | c14c==1)

	gen gravairp_uprod2=(gravairp_empleador2==1)

	*INDICADOR DE POTENCIAL DE PERSONAS QUE GRAVAN IRP POR RENTA DE UNIDAD PRODUCTIVA SIN CONSIDERAR INGRESOS
	gen gravairp_uprod=(gravairp_uprod1==1 | gravairp_uprod2==1)

	   lab var gravairp_uprod1 "Grava IRP por ingresos por uproductiva principal"
	   lab var gravairp_uprod2 "Grava IRP por ingresos por uproductiva secundaria"
	   lab var gravairp_uprod "Grava IRP por ingresos por uproductiva principal o secundaria"
	   
* B2. Calcula ingresos que gravan 

	*Variable de ingreso principal para personas que gravan IRP 
	gen e01aimdeb2_uprod = 0
	replace e01aimdeb2_uprod = e01aimdeb2 if gravairp_uprod1==1

	*Variable de ingreso secundario para personas que gravan IRP
	gen e01bimdeb2_uprod = 0
	replace e01bimdeb2_uprod = e01bimdeb2 if gravairp_uprod2==1

	*Ingreso terciario no se considera porque no hay informacion de formalidad para empleadores

	*Total ingreso por unidad productiva para los que cumplen con criterios de formalidad
	egen double tot_inc_uprod=rsum(e01aimdeb2_uprod e01bimdeb2_uprod)

	lab var e01aimdeb2_uprod "Taxable income from primary occupation net of SSC - Uproductiva"
	lab var e01bimdeb2_uprod "Taxable income from secondary occupation net of SSC - Uproductiva"
	lab var tot_inc_uprod "Taxable income - from Uproductiva"

	
* C. Renta de capital
* C1. Determina si grava
**Renta por capital ----> A estos NO se les aplica ninguna deduccion y tributan a una tasa unica de 8%, tampoco se les aplica criterios de formalidad

* C2. Calcula ingreso que grava
	gen double tot_inc_dividendo=e01ede
	gen double tot_inc_alquiler = e01dde
	replace tot_inc_dividendo = 0 if decili<5
	replace tot_inc_alquiler = 0 if decili<4
	
	lab var tot_inc_dividendo "Income from dividends"
	lab var tot_inc_alquiler "Income from rents"

	
	
	*INDICADOR DE POTENCIAL DE PERSONAS QUE GRAVAN IRP POR CAPITAL
	gen gravairp_alquiler=(tot_inc_alquiler>0 & !missing(tot_inc_alquiler) ) //individuos que obtienen renta por alquiler 
	gen gravairp_dividendo=(tot_inc_dividendo>0 & !missing(tot_inc_dividendo) ) //individuos que obtienen renta por alquiler
	lab var gravairp_alquiler "Has income from rents"
	lab var gravairp_dividendo "Has income from dividends"


*===============================================================================
//Let's add other incomes
*===============================================================================

	egen double pension_inc = rsum(`pension_inc')
		lab var pension_inc "Pension and retirement incomes"
	egen double capital_incs = rsum(`capital_incs')
		lab var capital_incs "Capital incomes"
	gen agro_inc = `agro'
		lab var agro_inc "Other income from agro"
	rename `imp_rent' rent_inc
		lab var rent_inc "Imputed rent income"
	egen transfer_inc = rsum(`transfers')
		lab var transfer_inc "Income from transfers"
		
sum deductible_irp



dis as error("running new system 3.2 dofile")