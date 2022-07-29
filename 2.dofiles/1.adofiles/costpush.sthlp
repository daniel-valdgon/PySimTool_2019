{smcl}
{* *! version 1.0.0  17September2018}{...}
{cmd:help costpush}
{hline}

{title:Title}

{p2colset 5 24 26 2}{...}
{p2col :{cmd:costpush} {hline 1} Including the Direct and Indirect Effects of Indirect Taxes and Subsidies}{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 23 2}
{opt costpush} {varlist} {ifin} {cmd:,} 
{opt FIXed(varlist max=1 numeric)}
{opt PRICEshock(varlist max=1 numeric)}
{opt genptot(newvarname)}
{opt genpind(newvarname)}
[{opt fix}]


{title:Description}

{pstd}
{cmd:costpush} Creates a vector of indirect and total price 
changes due to price shock. The input data is assumed to be a square matrix where 
each observation i and variable i represent the same sector of the economy, 
and its value is a technology coefficient.

{title:Options}

{phang}
{opt fixed} Variable containing the indicator (1=fixed or 0=not fixed) to denote if each sector of the economy has fixed prices. 

{phang}
{opt priceshock} Variable indicating the price shock to each sector (i) of the economy.

{phang}
{opt genptot} New variable name that will be filled with the total price effects for each sector. Variable must not exist in dataset.

{phang}
{opt genpind} New variable name that will be filled with the indirect price effects for each sector. Variable must not exist in dataset.

{phang}
{opt fix} Optional, and requests that when obtaining indirect effects fixed sectors are immune to price changes. Thus indirect for sector i = 0.



{title:Example}

clear all
set more off
//3X3 matrix from CEQ ch7 example
set obs 3
forval z=1/3{
        gen sector`z' = 0
}

replace sector1 = 40/120 in 1
replace sector1 = 15/120 in 2
replace sector1 =  2/120 in 3

replace sector2 =  5/75 in 1
replace sector2 = 35/75 in 2
replace sector2 = 22/75 in 3

replace sector3 =  7/80 in 1
replace sector3 =  7/80 in 2
replace sector3 = 10/80 in 3

gen fixed = 0
replace fixed = 1 in 2  //Sector 2 is fixed

gen dp = 0
replace dp = 0.1 in 2 //Sector 2 has a 10% price shock

costpush sector*, fixed(fixed) price(dp) genptot(total) genpind(indirect)
list total indirect
costpush sector*, fixed(fixed) price(dp) genptot(totalfix) genpind(indirectfix) fix
list totalfix indirectfix

{title:Author:}

{pstd}
Paul Corral{break}
The World Bank - Poverty and Equity Global Practice {break}
Washington, DC{break}
pcorralrodas@worldbank.org{p_end}


{pstd}
Any error or omission is the author's responsibility alone.


