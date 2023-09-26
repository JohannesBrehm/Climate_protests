
cap program drop eventstudy
program define eventstudy, eclass
version 15.0
**Änderungen: 
*Numlist bei reference() mit unendlich vielen Referenzkategorien möglich 
*Factorvar-Option überflüssig. Einfach Variablenliste hinter die ahängige schreiben
*Flexible Anpassung der Graphen möglich mit gr_opts(str) 
syntax [varlist(fv)] [if] [in] , eventvariable(varlist) reference(numlist)  [Absorb(varlist fv) cluster(varlist) level(real 0.05) supp_reg_output  keinbinning_pre keinbinning_post window_lower(real -100) window_upper(real -100) ///
	window_lower_graph(real -100) window_upper_graph(real -100) true(varlist) gr_opts(str) scproperties(str) rcapproperties(str) iv_endog(varlist) iv_instrument(varlist)]



	
quie {
if "`scproperties'"=="" local scproperties "mcolor(blue) msize(medium) msymbol(circle)"
numlist "`reference'"
local nn "`r(numlist)'"


********************************************************
* Vorschritt: zunächst die tatsächlichen Werte speichern
********************************************************




if "`true'" != "" {
preserve
collapse `true', by(`eventvariable')
tempfile true_dat
save `true_dat'
restore
}

 

************************************************************
* Eigentlicher Start: Variablen einlesen und generieren usw.
************************************************************


preserve

marksample touse
gettoken depvar varlist : varlist

loc eventvariable: list varlist | eventvariable
loc eventvariable: list eventvariable - varlist
global xvars `varlist' 

if "`cluster'" != "" {
loc cluster: list varlist | cluster
loc cluster: list cluster - varlist
loc cluster_reg "cluster(`cluster')"
}



* Default Effect-Window: Minimum und Maximum der Eventvariable
quie sum `eventvariable'
local max = r(max)
local min = r(min)
if `window_lower' == -100 local window_lower `min'
if `window_upper' == -100 local window_upper `max'




* Event-variablen im Effect-Fenster generieren
forvalues j = `window_lower'/-1 {
	local k = -1*`j'
	gen e_min`k' = `eventvariable' ==`j'
	}
forvalues j = 0/`window_upper' {
	gen e`j' = `eventvariable' == `j'
	}	
	

	

local i = `window_upper'	
local h = `window_lower'
*  Für das Binning eine weitere Kategorie erstellen
if `window_upper' < `max' &  "`keinbinning_post'" == ""  {
	local i = `window_upper' +1
	gen e`i' = `eventvariable' > `window_upper'
	replace e`i' = 0 if `eventvariable' == .
	}

if `window_lower' > `min' & "`keinbinning_pre'" == ""  {	
	local h = `window_lower' -1
	local hh = -1*`h'
	gen e_min`hh' = `eventvariable' < `window_lower' 
	}







	
**************************
* Global mit Eventdummies
**************************	
global event_vars
forvalues j = `h'/`i' {
	if `: list j in nn'==0 {    /*`reference2' == -100 als default, wenn zweiter Wert nicht angegeben) */
	local k = -1*`j'
	if `j' < 0 & `j' >= `min'  global event_vars $event_vars e_min`k'  /* Hier auch sicherstellen, dass Event-dummies außerhalb von min und max der Eventvariablen nicht mit aufgenommen werden. */
	if `j' >= 0 & `j' <= `max'  global event_vars $event_vars e`j'
}
}



*************************
* Regression
*************************

if "`supp_reg_output'"=="" local no no

if "`iv_endog'" == "" {
if "`absorb'"=="" 	`no' reg 		`depvar' $event_vars $xvars, `cluster_reg'
else				`no' reghdfe 	`depvar' $event_vars $xvars, `cluster_reg' absorb(`absorb')
}

if "`iv_endog'" != "" {
	noi di "`depvar' (`iv_endog' = `iv_instrument') $event_vars $xvars, `cluster_reg'"
	`no' ivregress 2sls 	`depvar' (`iv_endog' = `iv_instrument') $event_vars $xvars, `cluster_reg'
}


*est store results
*`no'  esttab results, se(3) label star(* 0.1 ** 0.05 *** 0.01) b(3)  lines wide replace nogaps title(`depvar') keep($event_vars)




		
* Ein paar Infos damit man auch ohne Regressionsoutput versteht, was gemacht wurde:
count if e(sample)
local obs = r(N)
count if e(sample) & `eventvariable' == . 
local obs_control = r(N)

noi di "Information on the event study regressions:"
noi di "Reference category: `nn'"
no display "Number of observations in the regression: " `obs'
if `obs_control' != 0 {
 no display `obs_control' " observations did not receive a treatment and are a pure control group."
 no display "They enter the regressions with all event-time indicators set to 0."
 }


*************************
* Grafik
*************************

mat b = e(b)
mat V = e(V)

local rows = (-1*`h') + (`i') + 1  /* alle negativen und positiven + die 0  */
mat def results = J(`rows',3,.)



local k = 0  /* Zähler für jede Zeile der zu erstellenden Ergebnismatrix (inklusive Referenzgruppen) */
local kk = 0  /* Zähler für jede Zeile des genutzten Regressionsoutputs (ohne Referenzgruppen) */ 
if "`iv_endog'" != "" local kk = 1 /* Endogene Variable bei IV wird oben angezeigt, verschiebt dann die Eventdummies */
forvalues j = `h'/`i' {
	local k = `k' + 1
	mat results[`k',1] = `j'


if `: list j in nn'==0 {
	local kk = `kk' + 1
	mat results[`k',2] = b[1,`kk']
	mat results[`k',3] = sqrt(V[`kk',`kk'])
	}

if `: list j in nn'==1 {
	mat results[`k',2] = 0
	mat results[`k',3] = 0
	}
}



clear
set obs 1

svmat results
rename results1 `eventvariable'
rename results2 `depvar'
gen ciu = `depvar' - `=invnormal(1-`level'/2)'*results3
gen cio = `depvar' + `=invnormal(1-`level'/2)'*results3



if "`true'" != "" {
	sort `eventvariable'
	merge `eventvariable' using `true_dat' 
	drop _merge
	local grafiktrue (line `true' `eventvariable', lwidth(thick) lpattern(dash) lcolor(red) )  
}


* Default ist Länge Effect window.
if `window_lower_graph' == -100  local window_lower_graph `window_lower'
if `window_upper_graph' == -100  local window_upper_graph `window_upper'

drop if `eventvariable' < `window_lower_graph' |  `eventvariable' > `window_upper_graph'

	

twoway  (scatter `depvar' `eventvariable', sort `scproperties') ///
		(rcap ciu  cio `eventvariable', `rcapproperties')  `grafiktrue' ///
		, ytitle(Effect) yline(0, lwidth(medium) lpattern(dash) lcolor(black)) xtitle(Time relative to protest (14 day aggregation)) title("$title") xscale(range(`window_lower_graph' (1) `window_upper_graph')) xlabel(`window_lower_graph'(1)`window_upper_graph') ///
			xline(-0.5, lwidth(medium) lpattern(dash) lcolor(black)) legend(off) scheme(s2mono) `gr_opts' ///
		graphregion(color(white)) 

		

		
		
		

restore



}

end


