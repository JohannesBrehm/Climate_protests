/******************************************************************************* 	
*	Replication files: Climate protests increase concerns about climate change *
********************************************************************************
*											 					               *
*	PURPOSE: 	Supplementary Tab. 3 – Treatment effects over time.		  	   * 
*					   										                   *
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
	
*** Drop if outcome variable missing 
	drop if agg_climate_concern== . 

************************************************************************************
*	Supplementary Tab. 3 – Treatment effects over time.					 			* 
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
	

	
	
	replace e_14d = e_14d + 4
	reghdfe agg_climate_concern ib3.e_14d#i.post_all $X $weather i.election_cop $interview_X  , a($delta i.event_id i.l11101 i.year i.month i.weekday_numeric)  cluster(i.event_id) 
	
*** Number of relevant observations by time window 
	gen byte used=e(sample)
	tab e_14d if used == 1
	
*** table 
reghdfe agg_climate_concern ib3.e_14d#i.post_all $X  , a(i.event_id  i.year)  cluster(i.event_id) 
	eststo tab1
	reghdfe agg_climate_concern ib3.e_14d#i.post_all $X  , a(i.event_id i.year i.month i.weekday_numeric)  cluster(i.event_id) 
	eststo tab2
	reghdfe agg_climate_concern ib3.e_14d#i.post_all $X $weather i.election_cop  , a(i.event_id i.year i.month i.weekday_numeric)  cluster(i.event_id) 
	eststo tab3
	reghdfe agg_climate_concern ib3.e_14d#i.post_all $X $weather i.election_cop $interview_X  , a(i.event_id  i.year i.month i.weekday_numeric)  cluster(i.event_id) 
	eststo tab4
	reghdfe agg_climate_concern ib3.e_14d#i.post_all $X $weather i.election_cop $interview_X  , a(i.event_id i.l11101 i.year i.month i.weekday_numeric)  cluster(i.event_id) 
	eststo tab5
	reghdfe agg_climate_concern ib3.e_14d#i.post_all $X $weather i.election_cop $interview_X  , a($delta i.event_id i.l11101 i.year i.month i.weekday_numeric)  cluster(i.event_id) 
	eststo tab6
	
	*** Output table
	estout tab1 tab2 tab3 tab4 tab5 tab6 using  "${graphdir}\eventstudy.tex", ///
                                style(tex) cells(b(star fmt(4)) se(par fmt(4)) p(par([ ]))) posthead() ///
                starlevels( * 0.1 ** 0.05 *** 0.01)   ///
                stats(N, layout(@ @) labels("Number of observations"))  mlabels(none)   ///
                collabels(none) eql(none) notype label postfoot( \addlinespace) replace        
    eststo clear
	
