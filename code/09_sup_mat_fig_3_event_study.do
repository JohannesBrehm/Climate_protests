/******************************************************************************* 	
*	Replication files: Climate protests increase concerns about climate change *
********************************************************************************
*											 					               *
*	PURPOSE: 	Supplementary Fig. 3 – Treatment effects over time.		  	   * 
*					   										                   *
*******************************************************************************/

*** Standard settings go here
	clear all
	set more off
	
*** Load data
	use "${datadir}\working_data_complete.dta", clear 
	
***Set globals

	*Controls 
	global X i.sex sex_missing size_hh size_hh_missing education education_missing age age_missing i.status_employment teen_14_18_hh i.teen_14_18_hh_missing status_employment_missing i.industry_employment industry_missing labour_income labour_income_missing i.strong_interest_politics strong_interest_politics_missing i.cat_pol_orient cat_pol_orient_missing
	
	*Weather 
	global weather hist_mean_prec_deviation hist_mean_prec_deviation_qu hist_mean_temp_deviation hist_mean_temp_deviation_qu 
	
	*Interviewer characteristics 
	global interview_X educ_int educ_int_missing gender_int gender_int_missing age_int age_int_missing
	
	*Region by protest FE
	global delta i.regionXprotest 
	
*** Drop if outcome variable missing 
	drop if agg_climate_concern== . 

************************************************************************************
*	Supplementary Fig. 3 – Treatment effects over time.					 			* 
************************************************************************************
	
*** Define time window 
	drop if e <-56
	drop if e >56

*** Load event study ado
	sysdir set PERSONAL "${dodir}\ado"
		
** Aggregate for event study 
	gen e_14d = .
	replace e_14d = -4 if e >= -56 & e <= -43
	replace e_14d = -3 if e >= -42 & e <= -29
	replace e_14d = -2 if e >= -28 & e <= -15
	replace e_14d = -1 if e >= -14 & e <=-1
	replace e_14d = 0 if e >= 1 & e <= 14
	replace e_14d = 1 if e >= 15 & e <= 28
	replace e_14d = 2 if e >= 29 & e <= 42
	replace e_14d = 3 if e >= 43 & e <= 56
	
*** Output event study
	eventstudy agg_climate_concern  $X  $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday) eventvariable(e_14d) window_lower(-4) window_upper(3) cluster(event_id) reference(-1)  

*** Export graph		  
	graph save "${graphdir}/eventstudy_main_results", replace
	graph export "${graphdir}/eventstudy_main_results.eps", as(eps) preview(off) replace
	