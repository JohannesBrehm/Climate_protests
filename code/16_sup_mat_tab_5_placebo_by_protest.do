/******************************************************************************** 	
*	Replication files: Climate protests increase concerns about climate change 	*
*********************************************************************************
*											 					              	*
*	Supplementary Tab. 5 - Placebo by protest								   	*
*																				*
*******************************************************************************/

*** Standard settings go here
	clear all
	set more off
	
*** Load data
	use "${datadir}\working_data_complete.dta", clear 
	
***Set globals
	
	*Controls 
	global X i.sex sex_missing size_hh size_hh_missing education education_missing i.status_employment teen_14_18_hh i.teen_14_18_hh_missing status_employment_missing i.industry_employment industry_missing labour_income labour_income_missing i.strong_interest_politics strong_interest_politics_missing i.cat_pol_orient cat_pol_orient_missing
	
	
	*Weather 
	global weather hist_mean_prec_deviation hist_mean_prec_deviation_qu hist_mean_temp_deviation hist_mean_temp_deviation_qu 
	
	*Interviewer characteristics 
	global interview_X educ_int educ_int_missing gender_int gender_int_missing age_int age_int_missing
	
	*Region by protest FE
	global delta i.regionXprotest 
	
	
*** Set standard time window for analysis 
	drop if e < -14
	drop if e > 14
	
********************************************************************************
*	 Supplementary Tab. 5 - Placebo results per protest		                   *
********************************************************************************

*** interaction of treatment effect with each protest
	foreach x in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 {
		gen post_`x' = 0 
		replace post_`x' = 1 if (event_id == `x' & post_all == 1)
	}
		
*** label variable
foreach x in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 {
	la var post_`x' "Protest `x'"
}
	
	
*** Systematic placebo test on entire battery of SOEP concerns which a part of the standard SOEP (Rohrer et al., 2021)

	** Generate aggregated concern variable analogue to climate change concern variable
	foreach v in plh0032 plh0033  plh0035 plh0036 plh0037 plh0038 plh0040 plh0042 plh0335 plj0046 plj0047 {
		gen agg_`v' = . 
		replace agg_`v' = 0 if `v' == 3 // No concerns
		replace agg_`v' = 1 if `v' == 2 // Some concerns
		replace agg_`v' = 1 if `v' == 1 // Strong concerns
	}

*** Label concern variables
	label var agg_plh0032  "Concerns about general economic development (Sorgen allgemeine wirtschaftliche Entwicklung)"
	label var agg_plh0033 "Concerns about own economic situation (Sorgen eigene wirtschaftliche Situation)"
	label var agg_plh0035 "Concerns own health (Sorgen eigene Gesundheit)"
	label var agg_plh0036 "Concerns protection environment (Sorgen Umweltschutz)"
	label var agg_plh0037 "Concerns consequences of climate change (Sorgen Klimawandelfolgen)"
	label var agg_plh0038 "Concerns peace (Sorgen Friedenserhaltung)"
	label var agg_plh0040 "Concerns about development of crime in Germany (Sorgen Kriminalitaetsentwicklung in Deutschland)"
	label var agg_plh0042 "Concerns job security (Sorgen Arbeitsplatzsicherheit)"
	label var agg_plh0335 "Concerns about own pension (Sorgen eigene Altersversorgung)"
	label var agg_plj0046 "Concerns immigration (Sorgen Zuwanderung)"
	label var agg_plj0047 "Concerns discrimination of foreigners (Sorgen Auslaenderfeindlichkeit)"
	
*** Entropy balancing for each outcome and individual protest
		foreach v in age sex education size_hh status_employment teen_14_18_hh labour_income {
		replace `v' = . if `v'_missing == 1
	} // to only balance on nonmissing observations


	tempfile ebal
	save `ebal'


	foreach i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 {
	use `ebal'
	keep if event_id == `i'
	
	tempfile placebo_outcome 
	save `placebo_outcome'
	
	drop if agg_plh0032 == .
	   ebalance post_all age sex education size_hh status_employment teen_14_18_hh labour_income, tar(1) gen(_webal_0032)
	tempfile weight_0032
	save `weight_0032'	
		
	use `placebo_outcome', clear 
		
	drop if agg_plh0033 == .
	   ebalance post_all age sex education size_hh status_employment teen_14_18_hh labour_income, tar(1) gen(_webal_0033)
	tempfile weight_0033
	save `weight_0033'			
		
	use `placebo_outcome', clear 
		
	drop if agg_plh0335 == .
	   ebalance post_all age sex education size_hh status_employment teen_14_18_hh labour_income, tar(1) gen(_webal_0335)
	tempfile weight_0335
	save `weight_0335'		
		
		use `placebo_outcome', clear 
		
	drop if agg_plh0035 == .
	   ebalance post_all age sex education size_hh status_employment teen_14_18_hh labour_income, tar(1) gen(_webal_0035)
	tempfile weight_0035
	save `weight_0035'		
		
	use `placebo_outcome', clear 
		
	drop if agg_plh0038 == .
	   ebalance post_all age sex education size_hh status_employment teen_14_18_hh labour_income, tar(1) gen(_webal_0038)
	tempfile weight_0038
	save `weight_0038'		
		
	use `placebo_outcome', clear 
		
	drop if agg_plh0040 == .
	   ebalance post_all age sex education size_hh status_employment teen_14_18_hh labour_income, tar(1) gen(_webal_0040)
	tempfile weight_0040
	save `weight_0040'		
		
	use `placebo_outcome', clear 
		
	drop if agg_plh0042 == .
	   ebalance post_all age sex education size_hh status_employment teen_14_18_hh labour_income, tar(1) gen(_webal_0042)
	tempfile weight_0042
	save `weight_0042'			
		
		use `placebo_outcome', clear 
		
	drop if agg_plj0046 == .
	   ebalance post_all age sex education size_hh status_employment teen_14_18_hh labour_income, tar(1) gen(_webal_0046)
	tempfile weight_0046
	save `weight_0046'	
	
	use `placebo_outcome', clear 
		
	drop if agg_plj0047 == .
	   ebalance post_all age sex education size_hh status_employment teen_14_18_hh labour_income, tar(1) gen(_webal_0047)
	tempfile weight_0047
	save `weight_0047'	
	

		
	append using `weight_0032'	
	append using `weight_0033'
	append using `weight_0335'
	append using `weight_0035'
	append using `weight_0038'
	append using `weight_0040'
	append using `weight_0042'
	append using `weight_0046'

		
		tempfile p`i'
		save `p`i''
	}

	append using `p1' 	
	append using `p2' 
	append using `p3' 
	append using `p4' 
	append using `p5' 
	append using `p6' 
	append using `p7' 
	append using `p8' 
	append using `p9' 
	append using `p10' 
	append using `p11' 
	append using `p12' 
	append using `p13' 
	append using `p14' 
	append using `p15' 
	append using `p16' 


		foreach v in age sex education size_hh status_employment teen_14_18_hh labour_income {
		replace `v' = 0 if `v'_missing == 1
	} 
	

	*** Placebo regressions
		tempfile placebo 
		save `placebo'
		  foreach v in 1 2 3 4 5 6 7 8 9 10 11 12 13 15 16 17 {
		  	keep if event_id == `v'
	reghdfe agg_plh0032 post_all $X $weather i.election_cop $interview_X  [aw=_webal_0032], a( i.l11101 i.month weekday)  vce(r)
	eststo tab1_`v'
	reghdfe agg_plh0033 post_all $X $weather i.election_cop $interview_X   [aw=_webal_0033], a( i.l11101 i.month weekday)  vce(r)
	eststo tab2_`v'
	reghdfe agg_plh0335 post_all $X $weather i.election_cop $interview_X   [aw=_webal_0335], a( i.l11101 i.month weekday) vce(r)
	eststo tab3_`v'

	reghdfe agg_plh0035 post_all $X $weather i.election_cop $interview_X  [aw=_webal_0035], a( i.l11101 i.month weekday)  vce(r)
	eststo tab4_`v'
	reghdfe agg_plh0038 post_all $X $weather i.election_cop $interview_X   [aw=_webal_0038], a( i.l11101 i.month weekday) vce(r)
	eststo tab5_`v'
	reghdfe agg_plh0040 post_all $X $weather i.election_cop $interview_X   [aw=_webal_0040], a( i.l11101 i.month weekday) vce(r)
	eststo tab6_`v'
	reghdfe agg_plh0042 post_all $X $weather i.election_cop $interview_X   [aw=_webal_0042], a( i.l11101 i.month weekday) vce(r)
	eststo tab7_`v'

	reghdfe agg_plj0046  post_all $X $weather i.election_cop $interview_X   [aw=_webal_0046], a( i.l11101 i.month weekday) vce(r)
	eststo tab8_`v'
	reghdfe agg_plj0047  post_all $X $weather i.election_cop $interview_X   [aw=_webal_0047], a( i.l11101 i.month weekday) vce(r)
	eststo tab9_`v'
	

		use `placebo', clear
}

		use `placebo', clear

	*** the estimation runs into computational problems for the 14th protest when including month fixed effects since it is perfectly collinear with the treatment effect. Therefore, we estimate the placebo results for this protest without month fixed effects.
		  foreach v in 14 {
		  	keep if event_id == `v'
	reghdfe agg_plh0032 post_all $X $weather i.election_cop $interview_X   [aw=_webal_0032], a( i.l11101  weekday)  vce(r)
	eststo tab1_`v'
	reghdfe agg_plh0033 post_all $X $weather i.election_cop $interview_X   [aw=_webal_0033], a( i.l11101  weekday)  vce(r)
	eststo tab2_`v'
	reghdfe agg_plh0335 post_all $X $weather i.election_cop $interview_X   [aw=_webal_0335], a( i.l11101  weekday) vce(r)
	eststo tab3_`v'

	reghdfe agg_plh0035 post_all $X $weather i.election_cop $interview_X  [aw=_webal_0035], a( i.l11101 weekday)  vce(r)
	eststo tab4_`v'
	reghdfe agg_plh0038 post_all $X $weather i.election_cop $interview_X   [aw=_webal_0038], a( i.l11101  weekday) vce(r)
	eststo tab5_`v'
	reghdfe agg_plh0040 post_all $X $weather i.election_cop $interview_X   [aw=_webal_0040], a( i.l11101  weekday) vce(r)
	eststo tab6_`v'
	reghdfe agg_plh0042 post_all $X $weather i.election_cop $interview_X   [aw=_webal_0042], a( i.l11101  weekday) vce(r)
	eststo tab7_`v'

	reghdfe agg_plj0046  post_all $X $weather i.election_cop $interview_X   [aw=_webal_0046], a( i.l11101  weekday) vce(r)
	eststo tab8_`v'
	reghdfe agg_plj0047  post_all $X $weather i.election_cop $interview_X   [aw=_webal_0047], a( i.l11101  weekday) vce(r)
	eststo tab9_`v'
		}
	

		use `placebo', clear

*** Output table
	foreach v in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 {
		
	estout tab1_`v' tab2_`v' tab3_`v' tab4_`v' tab5_`v' tab6_`v' tab7_`v' tab8_`v' tab9_`v'  using  "${graphdir}\placebo_per_protest_`v'.tex", ///
                                style(tex) cells(b(star fmt(4)) se(par fmt(4))) posthead() ///
                starlevels( * 0.1 ** 0.05 *** 0.01)   ///
                stats(N, layout(@ @) labels("Number of observations"))  mlabels(none)   ///
                collabels(none) eql(none) notype label postfoot( \addlinespace) replace        
	}
	
	



	
	