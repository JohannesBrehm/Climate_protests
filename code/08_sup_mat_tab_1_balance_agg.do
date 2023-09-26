/******************************************************************************* 	
*	Replication files: Climate protests increase concerns about climate change *
********************************************************************************
*											 					               *
*	Supplementary Tab. 1 – Balance Test Treatment and Control Group			   *
*																			   *									
*******************************************************************************/

*** Standard settings go here
	clear all
	set more off
	
*** Load data
	use "${datadir}\working_data_complete.dta", clear 
	
*** Set standard time window for analysis 
	drop if e < -14
	drop if e > 14
	
*** Drop if outcome variable missing 
	drop if agg_climate_concern== . 
	
	
************************************************************************************
*	Supplementary Tab. 1 – Balance Test Treatment and Control Group.			 	* 
************************************************************************************
	   
	tempfile balance 
	save `balance'
  
**Balance table not standardized
	reg age post_all i.event_id if age_missing == 0, r cluster(event_id)
		eststo balance_1
	reg sex post_all i.event_id if sex_missing == 0, r cluster(event_id)
		eststo balance_2
	reg size_hh post_all i.event_id if size_hh_missing == 0, r cluster(event_id)
		eststo balance_3
	reg education post_all i.event_id if education_missing == 0, r cluster(event_id)
		eststo balance_4
	reg status_employment post_all i.event_id if status_employment_missing == 0, r cluster(event_id)
		eststo balance_5
	reg teen_14_18_hh post_all i.event_id if teen_14_18_hh_missing == 0, r cluster(event_id)
		eststo balance_6
	reg labour_income post_all i.event_id if labour_income_missing == 0, r cluster(event_id)
		eststo balance_7
	reg strong_interest_politics post_all i.event_id if strong_interest_politics_missing == 0, r cluster(event_id)
		eststo balance_8
	reg cat_pol_orient post_all i.event_id if cat_pol_orient_missing == 0, r cluster(event_id)
		eststo balance_9
		
	**Balancing table	
		estout balance_1 balance_2 balance_3 balance_4 balance_5 balance_6 balance_7 balance_8 balance_9 using  "${graphdir}\balance_table.tex", ///
									style(tex) cells(b(star fmt(4)) se(par fmt(4))) posthead() ///
					starlevels( * 0.1 ** 0.05 *** 0.01)   ///
					stats(N, layout(@ @) labels("Number of observations"))  mlabels(none)   ///
					collabels(none) eql(none) notype label postfoot( \addlinespace) replace        
   
** Mean 
	sum age if age_missing == 0 
	sum sex if sex_missing == 0 
	sum size_hh if size_hh_missing == 0 
	sum education if education_missing == 0 
	sum status_employment if status_employment_missing == 0 
	sum teen_14_18_hh if teen_14_18_hh_missing == 0 
	sum labour_income if labour_income_missing == 0 
	sum strong_interest_politics if strong_interest_politics_missing == 0 
	sum cat_pol_orient if cat_pol_orient_missing == 0 
 
