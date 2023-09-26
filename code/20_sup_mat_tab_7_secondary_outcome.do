/******************************************************************************* 	
*	Replication files: Climate protests increase concerns about climate change *
********************************************************************************
*											 					               *
*	Supplementary Tab. 7 - Secondary outcome: concern envir. protection		   *
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
	
	*Global post_all 
	global post_all post_all
	
*** Set standard time window for analysis 
	drop if e < -14
	drop if e > 14
	
************************************************************************************
*	Supplementary Tab. 7 - Secondary outcome: concern envir. protection			   * 
************************************************************************************


*** Code concern environmental protection dummy (as climate change concerns)
		gen agg_plh0036 = . 
		replace agg_plh0036 = 0 if plh0036 == 3 // No concerns
		replace agg_plh0036 = 1 if plh0036 == 2 // Some concerns
		replace agg_plh0036 = 1 if plh0036 == 1 // Strong concerns
	
*** Label concern
	label var agg_plh0036 "Concerns protection environment (Sorgen Umweltschutz)"
	
*** Placebo regressions

	reghdfe agg_plh0036 $post_all $X , a(i.event_id  i.year)  cluster(i.event_id) 
	eststo tab1_plh0036
	reghdfe agg_plh0036 $post_all $X , a(i.event_id i.year i.month weekday)  cluster(i.event_id) 
	eststo tab2_plh0036
	reghdfe agg_plh0036 $post_all $X $weather i.election_cop  , a(i.event_id i.year i.month weekday)  cluster(i.event_id) 
	eststo tab3_plh0036
	reghdfe agg_plh0036 $post_all $X $weather i.election_cop $interview_X  , a(i.event_id i.year i.month weekday)  cluster(i.event_id) 
	eststo tab4_plh0036
	reghdfe agg_plh0036 $post_all $X $weather i.election_cop $interview_X  , a(i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 
	eststo tab5_plh0036
	reghdfe agg_plh0036 $post_all $X $weather i.election_cop $interview_X  , a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 
	eststo tab6_plh0036

*** Output table
		estout tab1_plh0036 tab2_plh0036 tab3_plh0036 tab4_plh0036 tab5_plh0036 tab6_plh0036 using  "${graphdir}\secondary_outcome_env_protection.tex", ///
					style(tex) cells(b(star fmt(4)) se(par fmt(4))) posthead() ///
					starlevels( * 0.1 ** 0.05 *** 0.01)   ///
					stats(N, layout(@ @) labels("Number of observations"))  mlabels(none)   ///
					collabels(none) eql(none) notype label postfoot( \addlinespace) replace    	


