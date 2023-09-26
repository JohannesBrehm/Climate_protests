/******************************************************************************** 	
*	Replication files: Climate protests increase concerns about climate change 	*
*********************************************************************************
*											 					              	*
*	PURPOSE: 	Generate estimates for Table 2a								   	*
*				- Linear Probability Model 										*
*				- Linear Probability Model + Entropy Balancing   				*
*				- Probit Model 									  				*
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
	
********************************************************************************
*	 Fig. 2a  Main regression analysis			                          	   *
********************************************************************************
	
*** Regressions
	
*** LPM
	reghdfe agg_climate_concern i.post_all $X  , a(i.event_id  i.year)  cluster(i.event_id) 
	eststo tab1
	reghdfe agg_climate_concern i.post_all $X  , a(i.event_id i.year i.month i.weekday_numeric)  cluster(i.event_id) 
	eststo tab2
	reghdfe agg_climate_concern i.post_all $X $weather i.election_cop  , a(i.event_id i.year i.month i.weekday_numeric)  cluster(i.event_id) 
	eststo tab3
	reghdfe agg_climate_concern i.post_all $X $weather i.election_cop $interview_X  , a(i.event_id  i.year i.month i.weekday_numeric)  cluster(i.event_id) 
	eststo tab4
	reghdfe agg_climate_concern i.post_all $X $weather i.election_cop $interview_X  , a(i.event_id i.l11101 i.year i.month i.weekday_numeric)  cluster(i.event_id) 
	eststo tab5
	reghdfe agg_climate_concern i.post_all $X $weather i.election_cop $interview_X  , a($delta i.event_id i.l11101 i.year i.month i.weekday_numeric)  cluster(i.event_id) 
	eststo tab6
	
	*** Output table
	estout tab1 tab2 tab3 tab4 tab5 tab6 using  "${graphdir}\main_results_all_lpm.tex", ///
                                style(tex) cells(b(star fmt(4)) se(par fmt(4))) posthead() ///
                starlevels( * 0.1 ** 0.05 *** 0.01)   ///
                stats(N, layout(@ @) labels("Number of observations"))  mlabels(none)   ///
                collabels(none) eql(none) notype label postfoot( \addlinespace) replace        
    eststo clear

*** LPM with entropy balancing weights 

	** Generate entropby balancing weights at the first moment (means of covariates)
		foreach v in age sex education size_hh status_employment teen_14_18_hh labour_income{
		replace `v' = . if `v'_missing == 1
	} // to only balance on nonmissing observations
	
	
	** Generate entropy balancing weights
	ebalance post_all age sex education size_hh status_employment teen_14_18_hh labour_income, tar(1)
	sum _webal 
	
		foreach v in age sex education size_hh status_employment teen_14_18_hh labour_income{
		replace `v' = 0 if `v'_missing == 1
	}
	
	
*** LPM + entropy balancing weights
	reghdfe agg_climate_concern i.post_all $X  [aw=_webal], a(i.event_id  i.year)  cluster(i.event_id) 
	eststo tab1
	reghdfe agg_climate_concern i.post_all $X  [aw=_webal], a(i.event_id i.year i.month i.weekday_numeric)  cluster(i.event_id) 
	eststo tab2
	reghdfe agg_climate_concern i.post_all $X $weather i.election_cop  [aw=_webal], a(i.event_id i.year i.month i.weekday_numeric)  cluster(i.event_id) 
	eststo tab3
	reghdfe agg_climate_concern i.post_all $X $weather i.election_cop $interview_X  [aw=_webal], a(i.event_id  i.year i.month i.weekday_numeric)  cluster(i.event_id) 
	eststo tab4
	reghdfe agg_climate_concern i.post_all $X $weather i.election_cop $interview_X  [aw=_webal], a(i.event_id i.l11101 i.year i.month i.weekday_numeric)  cluster(i.event_id) 
	eststo tab5
	reghdfe agg_climate_concern i.post_all $X $weather i.election_cop $interview_X  [aw=_webal], a($delta i.event_id i.l11101 i.year i.month i.weekday_numeric)  cluster(i.event_id) 
	eststo tab6
	
	*** Output table
	estout tab1 tab2 tab3 tab4 tab5 tab6 using  "${graphdir}\main_results_all_lpm_with_ebal.tex", ///
                                style(tex) cells(b(star fmt(4)) se(par fmt(4))) posthead() ///
                starlevels( * 0.1 ** 0.05 *** 0.01)   ///
                stats(N, layout(@ @) labels("Number of observations"))  mlabels(none)   ///
                collabels(none) eql(none) notype label postfoot( \addlinespace) replace        
    eststo clear

	
*** Probit model
	probit agg_climate_concern i.post_all $X  i.event_id i.year,  vce(cluster event_id)
	eststo tab13: margins, dydx(post_all) post
	probit agg_climate_concern i.post_all $X  i.event_id i.year i.month i.weekday_numeric,  vce(cluster event_id)
	eststo tab14: margins, dydx(post_all) post
	probit agg_climate_concern i.post_all $X $weather i.election_cop  i.event_id i.year i.month i.weekday_numeric,  vce(cluster event_id)
	eststo tab15: margins, dydx(post_all) post
	probit agg_climate_concern i.post_all $X $weather i.election_cop $interview_X  i.event_id i.year i.month i.weekday_numeric,  vce(cluster event_id)
	eststo tab16: margins, dydx(post_all) post
	probit agg_climate_concern i.post_all $X $weather i.election_cop $interview_X  i.event_id i.l11101 i.year i.month i.weekday_numeric,  vce(cluster event_id)
	eststo tab17: margins, dydx(post_all) post
	probit agg_climate_concern i.post_all $X $weather i.election_cop $interview_X  i.$delta i.event_id i.l11101 i.year i.month i.weekday_numeric,  vce(cluster event_id) 
	eststo tab18: margins, dydx(post_all) post
	
	*** Output table	
	estout tab13 tab14 tab15 tab16 tab17 tab18 using  "${graphdir}\main_results_all_probit.tex", ///
                                style(tex) cells(b(star fmt(4)) se(par fmt(4))) posthead() ///
                starlevels( * 0.1 ** 0.05 *** 0.01)   ///
                stats(N, layout(@ @) labels("Number of observations"))  mlabels(none)   ///
                collabels(none) eql(none) notype label postfoot( \addlinespace) replace        
    eststo clear
	

	