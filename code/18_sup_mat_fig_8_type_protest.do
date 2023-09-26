/******************************************************************************* 	
*	Replication files: Climate protests increase concerns about climate change *
********************************************************************************
*											 					               *
*	Supplementar Fig. 8:  Effects by dominant protest strategy				   *
*																			   *
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
	
	*Year FE
	global zeta i.year 
	
	*Global post_all 
	global post_all post_all
	
*** Set standard time window for analysis 
	drop if e < -14
	drop if e > 14
	
*** Drop if outcome variable missing 
	drop if agg_climate_concern== . 
	
*************************************************************************************
*	Supplementary Tab. 8a – Marginal effects with respect to						*
*	pre-protest level by dominant protest strategy							 		* 
*************************************************************************************

	
*** Analysis by pre-protest concern level
		
	bysort event_id post_all: egen mean_preconcern = mean(agg_climate_concern) 
	tab event_id mean_preconcern
	replace mean_preconcern = . if post_all == 1
		
	bysort event_id: egen mean_preconcern_full = max(mean_preconcern)

			
*** Interaction 
foreach x in demonstrative confrontational {
    gen post_`x' = 0 
	replace post_`x' = 1 if (`x' == 1 & post_all == 1)
}

*** Global tactic 
	global tactic 	post_demonstrative post_confrontational
	sum $tactic
	
	
	
*** Regression
	reghdfe agg_climate_concern post_demonstrative##c.mean_preconcern_full post_confrontational##c.mean_preconcern_full c.mean_preconcern_full#demonstrative c.mean_preconcern_full#confrontational  $X $weather i.election_cop $interview_X , a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 

	
*** Graph confrontational
	frame create orsCI mean_preconcern_full or orlb orub
	foreach a in  0.70 0.75 0.8 0.85 0.9 0.95  {
		lincom _b[1.post_confrontational] + _b[1.post_confrontational#c.mean_preconcern_full]*`a'
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
				  scheme(lean2)  graphregion(color(white)) legend(off) ylab(, nogrid) ylabel("") ///
			  yscale(range(-0.05(0.05)0.15)) title("Confrontational")
			  
	graph save confrontational, replace
	
*** Export graph	  
	graph save "${graphdir}/marginal_effects_preprotest_confrontational", replace
	graph export "${graphdir}/marginal_effects_preprotest_confrontational.eps", as(eps) preview(off) replace
	
	
	*** Graph demonstrative
	frame create orsCI2 mean_preconcern_full or orlb orub
	foreach a in  0.70 0.75 0.8 0.85 0.9 0.95  {
		lincom _b[1.post_demonstrative] + _b[1.post_demonstrative#c.mean_preconcern_full]*`a'
		frame post orsCI2 (`a') (`r(estimate)') (`r(lb)') (`r(ub)')
	}

	frame change orsCI2
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
				  scheme(lean2)  graphregion(color(white)) legend(off) ylab(, nogrid) ylabel(-0.05(0.05)0.15) ///
			  yscale(range(-0.05(0.05)0.15)) title("Demonstrative")


	graph save demonstrative, replace
	
*** Export graph	  
	graph save "${graphdir}/marginal_effects_preprotest_demonstrative", replace
	graph export "${graphdir}/marginal_effects_preprotest_demonstrative.eps", as(eps) preview(off) replace
	
	
*** graph combine 
	gr combine demonstrative.gph confrontational.gph,   graphregion(color(white)) 

*** export graph 
	graph save "${graphdir}/marginal_effects_preprotest_protesttypecombined", replace
	graph export "${graphdir}/marginal_effects_preprotest_protesttypecombined.eps", as(eps) preview(off) replace
	
	

*************************************************************************************
*	Supplementary Tab. 8b – Heterogeneous effects of type of protest	 			* 
*************************************************************************************

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
	
	*Global post_all 
	global post_all post_all
	
*** Set standard time window for analysis 
	drop if e < -14
	drop if e > 14
	
	
*** Drop if outcome variable missing 
	drop if agg_climate_concern== . 
	
	
	

*** Interaction 
foreach x in demonstrative confrontational {
    gen post_`x' = 0 
	replace post_`x' = 1 if (`x' == 1 & post_all == 1)
}

*** Global tactic 
	global tactic post_demonstrative post_confrontational
	sum $tactic
	
		
*** Political orientation
	
	** Generate variables	
		foreach var of varlist right center left {
		gen `var'_post = `var' * post_all
		}
		
		foreach var of varlist right center left {
		gen `var'_demonstrative = `var' * demonstrative
		gen `var'_confrontational = `var' * confrontational
		}
		
		
		foreach var of varlist demonstrative confrontational {
		gen `var'_right_post = `var' * right_post
		gen `var'_center_post = `var' * center_post
		gen `var'_left_post = `var' * left_post
		}
		
		
	** Regression 
		reghdfe agg_climate_concern demonstrative_right_post demonstrative_center_post demonstrative_left_post confrontational_right_post confrontational_center_post confrontational_left_post ///
		i.right_demonstrative i.right_confrontational i.center_demonstrative i.center_confrontational i.left_demonstrative i.left_confrontational ///
		i.right i.center i.left ///
		i.confrontational i.demonstrative ///
		$X $weather i.election_cop $interview_X , a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 
		eststo heter_politics

*** Label variables
	label var demonstrative_right_post "Right-leaning"
	label var demonstrative_center_post "Center-leaning"
	label var demonstrative_left_post "Left-leaning"
	label var confrontational_right_post "Right-leaning"
	label var confrontational_center_post "Center-leaning"
	label var confrontational_left_post "Left-leaning"

*** Plot coefficients

	coefplot ///
		  heter_politics  ///
          , keep(  demonstrative_right_post demonstrative_center_post demonstrative_left_post confrontational_right_post confrontational_center_post confrontational_left_post) xline(0, lc(cranberry)) grid(none)  ///
              scheme(lean2)  color(navy)  ciopts(lc(navy) recast(rcap) lwidth(thin) msize(small))  graphregion(color(white)) 	legend(off) xlabel(-0.04(0.04)0.08) ///
			  xscale(range(-0.04(0.04)0.08)) ///
			  headings(demonstrative_right_post = "{bf:Demonstrative}" ///
			  confrontational_right_post = "{bf:Confrontational}")
			  
			  
*** Export graph		  
	graph save "${graphdir}/coefplot_heterogeneity_protesttypecombined", replace
	graph export "${graphdir}/coefplot_heterogeneity_protesttypecombined.eps", as(eps) preview(off) replace
	