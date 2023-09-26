/******************************************************************************** 	
*	Replication files: Climate protests increase concerns about climate change 	*
*********************************************************************************
*											 					              	*
*	Supplementary Fig. 7 - Main results by individual climate protest			*
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
	
	*Year FE
	global zeta i.year 
	
*** Set standard time window for analysis 
	drop if e < -14
	drop if e > 14
	
*** Drop if outcome variable missing 
	drop if agg_climate_concern== . 


************************************************************************************
*** Supplementary Fig. 7: Main results by protests								 *** 
************************************************************************************

*** Generate post_protest variable for interactions
	foreach x in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 {
		gen post_`x' = 0 
		replace post_`x' = 1 if (event_id == `x' & post_all == 1)
	}

*** Label variables
	foreach x in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 {
		la var post_`x' "Protest `x'"
	}
	
*** Generate entropy balancing weights per protest, merge protests back into one file
	foreach v in age sex education size_hh status_employment teen_14_18_hh labour_income{
		replace `v' = . if `v'_missing == 1
	} // to only balance on nonmissing observations


	tempfile ebal
	save `ebal'

	foreach i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 {
	use `ebal'
	keep if event_id == `i'
	   ebalance post_all age sex education size_hh status_employment teen_14_18_hh labour_income, tar(1)
		tempfile p`i'
		save `p`i''
	}

	use `p17', clear
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
	
		foreach v in age sex education size_hh status_employment teen_14_18_hh labour_income{
		replace `v' = 0 if `v'_missing == 1
	}
	
	
	*Check correct number of observations
	sum _webal

	tempfile temp 
	save `temp'
	
*** LPM regressions with entropy balancing weights

	reghdfe agg_climate_concern post_1 post_2 post_3 post_4 post_5 post_6 post_7 post_8 post_9 post_10 post_11 post_12 post_13 post_14 post_15 post_16 post_17 ///
	$X [aw=_webal], a(i.event_id  i.year)  cluster(i.event_id) 
	eststo tab1
	
	reghdfe agg_climate_concern post_1 post_2 post_3 post_4 post_5 post_6 post_7 post_8 post_9 post_10 post_11 post_12 post_13 post_14 post_15 post_16 post_17 ///
	$X [aw=_webal], a(i.event_id i.year i.month i.weekday_numeric)  cluster(i.event_id) 
	eststo tab2
	reghdfe agg_climate_concern post_1 post_2 post_3 post_4 post_5 post_6 post_7 post_8 post_9 post_10 post_11 post_12 post_13 post_14 post_15 post_16 post_17 ///
	$X $weather i.election_cop [aw=_webal], a(i.event_id i.year i.month i.weekday_numeric)  cluster(i.event_id) 
	eststo tab3
	reghdfe agg_climate_concern post_1 post_2 post_3 post_4 post_5 post_6 post_7 post_8 post_9 post_10 post_11 post_12 post_13 post_14 post_15 post_16 post_17 ///
	$X $weather i.election_cop $interview_X  [aw=_webal], a(i.event_id  i.year i.month i.weekday_numeric)  cluster(i.event_id) 
	eststo tab4
	reghdfe agg_climate_concern post_1 post_2 post_3 post_4 post_5 post_6 post_7 post_8 post_9 post_10 post_11 post_12 post_13 post_14 post_15 post_16 post_17 ///
	$X $weather i.election_cop $interview_X  [aw=_webal], a(i.event_id i.l11101 i.year i.month i.weekday_numeric)  cluster(i.event_id) 
	eststo tab5
	reghdfe agg_climate_concern post_1 post_2 post_3 post_4 post_5 post_6 post_7 post_8 post_9 post_10 post_11 post_12 post_13 post_14 post_15 post_16 post_17 ///
	$X $weather i.election_cop $interview_X [aw=_webal], a($delta i.event_id i.l11101 i.year i.month i.weekday_numeric)  cluster(i.event_id) 
	eststo tab6
	
	
*** Generate coefplots without y-axis
	foreach i in  2 3 4 5  7 8 9 10  12  13 14 15  17   {	  
			coefplot ///
		  (tab1), bylabel(" ")  || ///
		  (tab2), bylabel(" ")  || ///
		  (tab3), bylabel(" ")  || ///
		  (tab4), bylabel(" ")  || ///
		  (tab5), bylabel(" ")  || ///
		  (tab6), bylabel(" ")  || ///
          , keep(post_`i') xline(0, lc(cranberry))  grid(none) ///
          bycoefs horizontal subtitle(, bcolor(white))  scheme(lean2) color(navy) ciopts(lc(navy) recast(rcap) lwidth(thin) msize(small)) graphregion(color(white)) ///
		  byopts(graphregion(col(white)) rows(4) bgcol(white))  xlabel(-0.2(0.1)0.2) xscale(range(-0.2(0.1)0.2)) title("Protest `i'", size(medium)) // adjust how many rows appear // "compact" is also potentially interesting option
		graph save balance`i', replace  
	}
			  
*** Generate coefplots with y-axis
		  
	foreach i in 1 6 11 16{
			coefplot ///
		  (tab1), bylabel("(1)")  || ///
		  (tab2), bylabel("(2)")  || ///
		  (tab3), bylabel("(3)")  || ///
		  (tab4), bylabel("(4)")  || ///
		  (tab5), bylabel("(5)")  || ///
		  (tab6), bylabel("(6)")  || ///
          , keep(post_`i') xline(0, lc(cranberry))  grid(none) ///
 bycoefs horizontal subtitle(, bcolor(white))  scheme(lean2) color(navy) ciopts(lc(navy) recast(rcap) lwidth(thin) msize(small)) graphregion(color(white)) ///
		  byopts(graphregion(col(white)) rows(4) bgcol(white))  xlabel(-0.2(0.1)0.2) xscale(range(-0.2(0.1)0.2)) title("Protest `i'", size(medium)) groups(?.tab1 ?.tab6 = "{bf:Main Effects}") 
		  
		graph save balance`i', replace  
	}
			 
*** Combine graphs	 
		gr combine balance1.gph balance2.gph balance3.gph balance4.gph balance5.gph balance6.gph balance7.gph balance8.gph balance9.gph balance10.gph balance11.gph balance12.gph balance13.gph balance14.gph balance15.gph balance16.gph balance17.gph,  graphregion(color(white))
		
*** Export graph
	graph export "${graphdir}/results_by_protest_ebalance.eps", as(eps) preview(off) replace
