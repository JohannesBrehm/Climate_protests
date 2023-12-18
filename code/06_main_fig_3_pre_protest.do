/******************************************************************************** 	
*	Replication files: Climate protests increase concerns about climate change 	*
*********************************************************************************
*											 					              	*
*	PURPOSE: 	Generate estimates for Figure 3								   	*
*				- Analysis by pre-protest concern level							*
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
	
*********************************************************************************
*	Analysis by pre-protest concern level										*
*********************************************************************************

*** Analysis by pre-protest concern level
		
	bysort event_id post_all: egen mean_preconcern = mean(agg_climate_concern) 
	tab event_id mean_preconcern
	replace mean_preconcern = . if post_all == 1
		
	bysort event_id: egen mean_preconcern_full = max(mean_preconcern)

*** Regression
	reghdfe agg_climate_concern post_all##c.mean_preconcern_full $X $weather i.election_cop $interview_X  , a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 

*** Graph
	frame create orsCI mean_preconcern_full or orlb orub
	foreach a in  0.70 0.75 0.8 0.85 0.9 0.95  {
		lincom _b[1.post_all] + _b[1.post_all#c.mean_preconcern_full]*`a'
		frame post orsCI (`a') (`r(estimate)') (`r(lb)') (`r(ub)')
	}

	frame change orsCI
	*isid mean_preconcern_full, sort
	format or %3.2f
	format orlb %3.2f
	format orub %3.2f
	list, noobs clean

	la var mean_preconcern_full "Pre-protest concern level"
	label var or "Marginal effect"
	label var orub "95% CI"
	label var orlb "95% CI"
	graph twoway (scatter  or mean_preconcern_full , sort) (rcap  orlb  orub mean_preconcern_full ,  color(navy) lwidth(thin) msize(small) ), yline(0, lc(cranberry)) ///
				  scheme(lean2)  graphregion(color(white)) legend(off) ylab(, nogrid)

*** Export graph	  
	graph save "${graphdir}/marginal_effects_preprotest", replace
	graph export "${graphdir}/marginal_effects_preprotest.eps", as(eps) preview(off) replace