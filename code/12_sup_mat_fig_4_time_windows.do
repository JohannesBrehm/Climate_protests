/******************************************************************************* 	
*	Replication files: Climate protests increase concerns about climate change *
********************************************************************************
*											 					               *
*	Supplementary Fig. 4 – Treatment effects for alternative time windows 	   * 
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
	
	*Global post_all 
	global post_all post_all
	
************************************************************************************
*	Supplementary Fig. 4 – Treatment effects for alternative time windows 			* 
************************************************************************************

*** A) Different time windows 

	*bandwidths 
	tempfile bandwidth
	save `bandwidth'
	
	drop if e < -90 | e > 90
	reghdfe agg_climate_concern $post_all $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id)  
	eststo bw90
	
	drop if e < -60 | e > 60
	reghdfe agg_climate_concern $post_all $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id)  
	eststo bw60
	
	drop if e < -30 | e > 30
	reghdfe agg_climate_concern $post_all $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id)  
	eststo bw30
	
	drop if e < -25 | e > 25
	reghdfe agg_climate_concern $post_all $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id)  
	eststo bw25
	
	drop if e < -20 | e > 20
	reghdfe agg_climate_concern $post_all $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id)  
	eststo bw20
	
	drop if e < -15 | e > 15
	reghdfe agg_climate_concern $post_all $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 
	eststo bw15
	
	drop if e < -14 | e > 14
	reghdfe agg_climate_concern $post_all $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id)  
	eststo bw14
	
	drop if e < -13 | e > 13
	reghdfe agg_climate_concern $post_all $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id)  
	eststo bw13
	
	drop if e < -12 | e > 12
	reghdfe agg_climate_concern $post_all $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id)  
	eststo bw12
	
	drop if e < -11 | e > 11
	reghdfe agg_climate_concern $post_all $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 
	eststo bw11
	
	drop if e < -10 | e > 10
	reghdfe agg_climate_concern $post_all $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id)  
	eststo bw10
	
	drop if e < -9 | e > 9
	reghdfe agg_climate_concern $post_all $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 
	eststo bw9
	
	drop if e < -8 | e > 8
	reghdfe agg_climate_concern $post_all $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id)  
	eststo bw8
	
	drop if e < -7 | e > 7
	reghdfe agg_climate_concern $post_all $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id)  
	eststo bw7
	
	drop if e < -6 | e > 6
	reghdfe agg_climate_concern $post_all $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 
	eststo bw6
	
	drop if e < -5 | e > 5
	reghdfe agg_climate_concern $post_all $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 
	eststo bw5
	
	drop if e < -4 | e > 4
	reghdfe agg_climate_concern $post_all $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id)  
	eststo bw4
	
	drop if e < -3 | e > 3
	reghdfe agg_climate_concern $post_all $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 
	eststo bw3
	

	coefplot ///
		  bw90, bylabel("90") || ///
		  bw60, bylabel("60") || ///
		  bw30, bylabel("30") || ///
		  bw25, bylabel("25") || ///
		  bw20, bylabel("20") || ///
		  bw15, bylabel("15") || ///
	      bw14, bylabel("14") || ///
          bw13, bylabel("13") || ///
          bw12, bylabel("12") || ///
          bw11, bylabel("11") || ///
		  bw10, bylabel("10") || ///
          bw9, bylabel("9") || ///
		  bw8, bylabel("8") || ///
          bw7, bylabel("7") || ///
		  bw6, bylabel("6") || ///
		  bw5, bylabel("5") || ///
		  bw4, bylabel("4") || ///
		  bw3, bylabel("3") || ///
          , keep(post_all) xline(0, lc(cranberry))  grid(none) ///
		  headings( ///
          1="Bandwidth") ///
          bycoefs          scheme(lean2) color(navy) ciopts(lc(navy) recast(rcap) lwidth(thin) msize(small)) swapnames graphregion(color(white))
	
	
*** Export graphs
	graph save "${graphdir}/coefplot_bandwidth", replace
	graph export "${graphdir}/coefplot_bandwidth.eps", as(eps) preview(off) replace
	
	
	use `bandwidth', clear

	
*** B) Anticipation effects

	
*** Set standard time windows
	drop if e < -14
	drop if e > 14

*** Consecutively dropping more days before a protest 

	* Drop 1 day before the protest
	drop if e == -1 
	reghdfe agg_climate_concern post_all $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 
	eststo agg_m1
	
	* Drop 2 days before the protest

	drop if e == -2
	reghdfe agg_climate_concern post_all $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 
	eststo agg_m2

	* Drop 3 days before the protest	
	drop if e == -3
	reghdfe agg_climate_concern post_all $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 
	eststo agg_m3

	* Drop 4 days before the protest
	drop if e == -4 
	reghdfe agg_climate_concern post_all $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 
	eststo agg_m4
	
	* Drop 5 days before the protest
	drop if e == -5
	reghdfe agg_climate_concern post_all $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 
	eststo agg_m5
	
	* Drop 6 days before the protest
	drop if e == -6
	reghdfe agg_climate_concern post_all $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 
	eststo agg_m6
	
	* Drop 7 days before the protest
	drop if e == -7 
	reghdfe agg_climate_concern post_all $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 
	eststo agg_m7
	
	* Plot results	  
	coefplot ///
	      agg_m1, bylabel("1") || ///
          agg_m2, bylabel("2") || ///
          agg_m3, bylabel("3") || ///
		  agg_m4, bylabel("4") || ///
		  agg_m5, bylabel("5") || ///
		  agg_m6, bylabel("6") || ///
		  agg_m7, bylabel("7") || ///
          , keep(post_all) xline(0, lc(cranberry)) grid(none) ///
           ytitle(Excluded pre-protest days) bycoefs scheme(lean2) color(navy) ciopts(lc(navy) recast(rcap) lwidth(thin) msize(small)) swapnames graphregion(color(white))
		 
*** Export graphs
	graph save "${graphdir}/coefplot_anticipation", replace
	graph export "${graphdir}/coefplot_anticipation.eps", as(eps) preview(off) replace
		  
