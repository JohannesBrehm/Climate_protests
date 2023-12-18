/******************************************************************************* 	
*	Replication files: Climate protests increase concerns about climate change *
********************************************************************************
*											 					               *
*	PURPOSE: Supplementary Tab. 8 – Intensive margin.						   *
*																			   *									
*******************************************************************************/

*** Standard settings go here
	clear all
	set more off
	
*** Load data
	use "${datadir}\working_data_complete.dta", clear 
	
***Set globals
	
	*Controls 
	global X i.sex sex_missing size_hh size_hh_missing education education_missing i.status_employment  status_employment_missing teen_14_18_hh i.teen_14_18_hh_missing i.industry_employment industry_missing labour_income labour_income_missing i.strong_interest_politics strong_interest_politics_missing i.cat_pol_orient cat_pol_orient_missing
	
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
			
*********************************************************************************
*	PART X:  Supplementary Tab. 8 – Intensive margin.						    * 
*********************************************************************************
		
*** Generate auxiliary variables for analysis
	gen cat_concern = . 
	replace cat_concern = 0 if plh0037 == 3
	replace cat_concern = 0.5 if plh0037 == 2 
	replace cat_concern = 1 if plh0037 == 1
	
	gen prob_no_concern = . 
	replace prob_no_concern = 1 if plh0037 == 3
	replace prob_no_concern = 0 if plh0037 == 2
	replace prob_no_concern = 0 if plh0037 == 1
	
	gen prob_some_concern= .
	replace prob_some_concern = 1 if plh0037 == 2
	replace prob_some_concern = 0 if plh0037 == 3
	replace prob_some_concern = 0 if plh0037 == 1
	
	gen prob_high_concern = .
	replace prob_high_concern = 1 if plh0037 == 1
	replace prob_high_concern = 0 if plh0037 == 2
	replace prob_high_concern = 0 if plh0037 == 3
	
*** Part 1 of table: Pr(no concern), Pr(some concern), Pr(high concern)
	reghdfe prob_no_concern i.post_all $X $weather i.election_cop $interview_X  , a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 
	eststo lpm1
	reghdfe prob_some_concern i.post_all $X $weather i.election_cop $interview_X  , a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 
	eststo lpm2
	reghdfe prob_high_concern i.post_all $X $weather i.election_cop $interview_X  , a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 
	eststo lpm3
	
*** Part 2 of table: Multionomial and generalized ordered logit that dont have the assumption

global X i.sex sex_missing education education_missing i.industry_employment industry_missing labour_income labour_income_missing i.strong_interest_politics strong_interest_politics_missing i.cat_pol_orient cat_pol_orient_missing // not controlling for household size, teenagers in household and employment status for the models to converge

	
	** Multinumial logit (does not converge?)
	mlogit cat_concern i.post_all $X $weather i.election_cop $interview_X  i.$delta i.event_id i.l11101 i.year i.month i.weekday_numeric, base(0.5)  vce(cluster event_id)
	eststo margins_multionomiallogit: margins, dydx(post_all) post
	
	** Generalized ordered logit	
	gologit2 cat_concern i.post_all $X $weather i.election_cop $interview_X  i.$delta i.event_id i.l11101 i.year i.month i.weekday_numeric,  vce(cluster event_id) 
	eststo margins_gologit: margins, dydx(post_all) post
	
*** Output table
	estout lpm1 lpm2 lpm3 margins_multionomiallogit margins_gologit using  "${graphdir}\intensive_margin_results.tex", ///
                style(tex) cells(b(star fmt(4)) se(par fmt(4)) p(par([ ]))) posthead() ///
                starlevels( * 0.1 ** 0.05 *** 0.01)   ///
                stats(N, layout(@ @) labels("Number of observations"))  mlabels(none)   ///
                collabels(none) eql(none) notype label postfoot( \addlinespace) replace        
    eststo clear
	
	

	