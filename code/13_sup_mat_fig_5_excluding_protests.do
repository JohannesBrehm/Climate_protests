/******************************************************************************* 	
*	Replication files: Climate protests increase concerns about climate change *
********************************************************************************
*											 					               *
*	Supplementary Fig. 5 – Iteratively excluding climate protests			   * 
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
	
	*Global post_all 
	global post_all post_all
	
*** Set standard time window for analysis 
	drop if e < -14
	drop if e > 14
	
************************************************************************************
*	Supplementary Fig. 5 – Iteratively excluding climate protests				 	* 
************************************************************************************

*** Tempfile
	tempfile leaveoneout
	save `leaveoneout'
	
	foreach x in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17  {
		use `leaveoneout', clear
		drop if event_id == `x'
		reghdfe agg_climate_concern $post_all $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 
	eststo tab_`x'
	}
	
	use `leaveoneout', clear
	
*** Coefficient plot
	coefplot ///
		(tab_1), bylabel(1)  || ///
		(tab_2), bylabel(2)  || ///
		(tab_3), bylabel(3)  || ///
		(tab_4), bylabel(4)  || ///
		(tab_5), bylabel(5)  || ///
		(tab_6), bylabel(6)  || ///
		(tab_7), bylabel(7)  || ///
	    (tab_8), bylabel(8)  || ///
        (tab_9), bylabel(9)  || ///
        (tab_10), bylabel(10)  || ///
        (tab_11), bylabel(11)  || ///
		(tab_12), bylabel(12)  || ///
        (tab_13), bylabel(13)  || ///
		(tab_14), bylabel(14)  || ///
        (tab_15), bylabel(15)  || ///
		(tab_16), bylabel(16)  || ///
		(tab_17), bylabel(17)  || ///
        , keep(post_all) xline(0, lc(cranberry))  grid(none) ///
		headings( ///
        1="Excluded Protest-id") ///
        bycoefs    horizontal     scheme(lean2) color(navy) ciopts(lc(navy) recast(rcap) lwidth(thin) msize(small)) swapnames graphregion(color(white))
	
*** Export graph	 
	graph save "${graphdir}/leave_one_out", replace
	graph export "${graphdir}/leave_one_out.eps", as(eps) preview(off) replace
	