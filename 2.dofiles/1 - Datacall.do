set more off
clear

*===============================================================================
// MACROS
*===============================================================================

local _addtop = $addtop

*===============================================================================
// Bring data for direct tax simulation into the tool
*===============================================================================
use "$indivdta", clear

if (`_addtop'==1) append using `topincs_5', gen(mysource)

egen linpobex_ =max(linpobex), by(area)
egen linpobto_ =max(linpobto), by(area)
drop linpobex linpobto


merge m:1 dptorep dpto_decile using "$data_pry\shrgasto_decildpto.dta", keepusing(med_prop_gasto_formal med_prop_gasto_trabajo)
drop if _m==2
drop _m

				
drop  p04 p04a p04b p05c p05p p05m p08d p08m p08a p09 p10a ///
 p11a p12 a01 a01a a02 a03 a04 a04a a05 a07 a08 a10 a11a a11m ///
a11s a12 a13rec a14rec a15 a16 a17a a17m a17s a18 b01c b01rec b02d b02c ///
b03lu b03ma b03mi b03ju b03vi b03sa b03do b04 b05 b06 b07a b07m b07s b08 b09a ///
b09m b09s b10 b13 b14 b15 b16g b16u b16d b16t b17 b18ag b18au b18bg b18bu ///
b19 b20g b20u b20d b20t b21 b22 b23 b24 b25 b26 b271 b272  b29  b31 c01c c02rec ///
c03 c04 c05 c06 c07 c101 c102 c11g c11u c11d c11t c12 c13ag c13au c13bg c13bu ///
c14 c14b c14c c15 c16c c17rec c18 c18a c18b c19 d01 d02 d03 d04 d05 e01a ///
e01b e01c e01d e01e e01f e01g e01h e01i e01j e01k e01l e01m ed01 ed02 ed03 ed0504 ///
ed06c  ed10 ed11c ed11d ed11e  ed12 ed13 ed14a ed14 ///
ed15  s02 s03 s04 s05 s06 s07 s08 s09 ///
horab horabc horabco njef ncon npad nmad tic01 tic02 tic03 ///
tic0401 tic0402 tic0403 tic0404 tic0405 tic0406 tic0407 tic0408 tic0409 tic0501 ///
tic0502 tic0503 tic0504 tic0505 tic0506 tic0507 tic0508 tic0509 tic0510 tic0511 ///
tic0512 tic0513 tic06 pobnopoi quintili quintiai ///
decilai b01d jefe menores menores_hh ing_imp decil_persona hijo hijo_h pareja ///
pareja_h papa mama papa_solviu mama_solviu separado mayores60 jefes_dis nojefes_dis ///
ed_jefes papa_solviu_h mama_solviu_h separado_h jefes_dis_h nojefes_dis_h ed_jefes_h ///
mayores60_hh men_teredad_h ips contpri contsec contpri2 contsec2 salud_count ///
ing_especie1 irpc5220b cod_ocuirp2 sociedad2 ///
irpc5220c cod_ocuirp3 tot_asalariados tot_empleadores_cuent eduuti ///

merge m:1 famunit using  "$data_pry\egi_eph_link_2019.dta"   , nogen


