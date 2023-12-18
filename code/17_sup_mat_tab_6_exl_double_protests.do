/******************************************************************************* 	
*	Replication files: Climate protests increase concerns about climate change *
********************************************************************************
*											 					               *
*	PURPOSE: Supplementary Tab. 4 – Excluding double protests.				   *
*																			   *									
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
	
*** Drop if outcome variable missing 
	drop if agg_climate_concern== . 
	
************************************************************************************
*	Supplementary Tab. 4 – Excluding double protests.							    * 
************************************************************************************
	
	*Show events that are double protests
	tab double_protest event_id
	
	*Drop double protests from analysis
	drop if double_protest == 1 
	
*** Regressions (LPM)
	reghdfe agg_climate_concern $post_all $X, a(i.event_id  i.year)  cluster(i.event_id) 
	eststo tab1
	reghdfe agg_climate_concern $post_all $X, a(i.event_id i.year i.month weekday)  cluster(i.event_id) 
	eststo tab2
	reghdfe agg_climate_concern $post_all $X $weather i.election_cop, a(i.event_id i.year i.month weekday)  cluster(i.event_id) 
	eststo tab3
	reghdfe agg_climate_concern $post_all $X $weather i.election_cop $interview_X, a(i.event_id  i.year i.month weekday)  cluster(i.event_id) 
	eststo tab4
	reghdfe agg_climate_concern $post_all $X $weather i.election_cop $interview_X, a(i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 
	eststo tab5
	reghdfe agg_climate_concern $post_all $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 
	eststo tab6
	
	estout tab1 tab2 tab3 tab4 tab5 tab6 using  "${graphdir}\robustness_double_protest.tex", ///
                                style(tex) cells(b(star fmt(4)) se(par fmt(4)) p(par([ ]))) posthead() ///
                starlevels( * 0.1 ** 0.05 *** 0.01)   ///
                stats(N, layout(@ @) labels("Number of observations"))  mlabels(none)   ///
                collabels(none) eql(none) notype label postfoot( \addlinespace) replace        
