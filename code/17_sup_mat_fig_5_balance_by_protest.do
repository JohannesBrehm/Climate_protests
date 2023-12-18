/******************************************************************************** 	
*   Replication files: Climate protests increase concerns about climate change 	*
*********************************************************************************
*																				*
*	Supplementary Fig. 5 - Balance by protest					  				*
*																				*
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
*** Supplementary Fig. 5a: Balancing by protest without weights					 *** 
************************************************************************************

*** Standardize variables 
	foreach v in age sex size_hh education status_employment teen_14_18_hh labour_income strong_interest_politics cat_pol_orient{
		egen z`v' = std(`v') if `v'_missing == 0 
	}

*** Generate post_protest variable for interactions
	foreach x in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 {
		gen post_`x' = 0 
		replace post_`x' = 1 if (event_id == `x' & post_all == 1)
	}

*** Label variables
	foreach x in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 {
		la var post_`x' "Protest `x'"
	}
	
*** Balance by protest (in two waves to avoid y-axis labeling)
	

	tempfile temp
	save `temp'

*** Without y-axis labels
	foreach i in  2 3 4 5  7 8 9 10  12  13 14 15  17   {
	
	// Individual loop for each protest ID with the corresponding sample size
	local sample_sizes_bal "2,751	813	190	388	386	5,579 2,305	1,542 658 380	234	2,688	3,790	663	643	858	698"
	local samplesize_bal : word `i' of `sample_sizes_bal'
    local title "Protest `i' (N=`samplesize_bal')"
	
	use `temp', clear
	
	keep if event_id == `i'
	
**Balance table standardized
	reg zage post_`i' if age_missing == 0, r 
		eststo balance_1
	reg zsex post_`i'  if sex_missing == 0, r 
		eststo balance_2
	reg zsize_hh post_`i'  if size_hh_missing == 0, r 
		eststo balance_3
	reg zeducation post_`i'  if education_missing == 0, r 
		eststo balance_4
	reg zstatus_employment post_`i'  if status_employment_missing == 0, r 
		eststo balance_5
	reg zteen_14_18_hh post_`i'  if teen_14_18_hh_missing == 0, r 
		eststo balance_6
	reg zlabour_income post_`i'  if labour_income_missing == 0, r 
		eststo balance_7
	reg zstrong_interest_politics post_`i'  if strong_interest_politics_missing == 0, r
		eststo balance_8
	reg zcat_pol_orient post_`i'  if cat_pol_orient_missing == 0, r 
		eststo balance_9

		coefplot ///
                   balance_1, bylabel(" ") ||  ///
                   balance_2, bylabel(" ") || ///
                   balance_3, bylabel(" ") || ///
                   balance_4, bylabel(" ") || ///
                   balance_5, bylabel(" ") || ///
                   balance_6, bylabel(" ") || ///
                   balance_7, bylabel(" ") || ///
                   balance_8, bylabel(" ") || ///
                   balance_9, bylabel(" ") || ///
          , keep(post_1 post_2 post_3 post_4 post_5 post_6 post_7 post_8 post_9 post_10 post_11 post_12 post_13 post_14 post_15 post_16 post_17) xline(0, lc(cranberry))  grid(none) ///
          bycoefs horizontal subtitle(, bcolor(white))  scheme(lean2) color(navy) ciopts(lc(navy) recast(rcap) lwidth(thin) msize(small)) graphregion(color(white)) ///
		  byopts(graphregion(col(white)) rows(5) bgcol(white)) xlabel(-1.0(0.5)1.0) xscale(range(-1.0(0.5)1.0))  title("`title'", size(medium))
		graph save balance`i', replace
		  
	}
	
		
	use `temp', clear
	
*** Balance by protest with y-axis labels
	foreach i in 1 6 11 16{
	
	// Individual loop for each protest ID with the corresponding sample size
	local samplesize_bal : word `i' of `sample_sizes_bal'
    local title "Protest `i' (N=`samplesize_bal')"
	
	use `temp', clear
	
		keep if event_id == `i'
		
**Balance table standardized
	reg zage post_`i'  if age_missing == 0, r 
		eststo balance_1
	reg zsex post_`i'   if sex_missing == 0, r 
		eststo balance_2
	reg zsize_hh post_`i'  if size_hh_missing == 0, r 
		eststo balance_3
	reg zeducation post_`i'   if education_missing == 0, r 
		eststo balance_4
	reg zstatus_employment post_`i'   if status_employment_missing == 0, r 
		eststo balance_5
	reg zteen_14_18_hh post_`i'   if teen_14_18_hh_missing == 0, r 
		eststo balance_6
	reg zlabour_income post_`i'   if labour_income_missing == 0, r 
		eststo balance_7
	reg zstrong_interest_politics post_`i'   if strong_interest_politics_missing == 0, r
		eststo balance_8
	reg zcat_pol_orient post_`i'   if cat_pol_orient_missing == 0, r 
		eststo balance_9
		

		coefplot ///
                   balance_1, bylabel("Age") ||  ///
                   balance_2, bylabel("Sex") || ///
                   balance_3, bylabel("HH size") || ///
                   balance_4, bylabel("Educ") || ///
                   balance_5, bylabel("STE") || ///
                   balance_6, bylabel("Teens") || ///
                   balance_7, bylabel("Income") || ///
                   balance_8, bylabel("Int Pol") || ///
                   balance_9, bylabel("Pol Or") || ///
          , keep(post_1 post_2 post_3 post_4 post_5 post_6 post_7 post_8 post_9 post_10 post_11 post_12 post_13 post_14 post_15 post_16 post_17) xline(0, lc(cranberry))  grid(none) ///
          bycoefs horizontal subtitle(, bcolor(white))  scheme(lean2) color(navy) ciopts(lc(navy) recast(rcap) lwidth(thin) msize(small)) graphregion(color(white)) ///
		  byopts(graphregion(col(white)) rows(5) bgcol(white)) xlabel(-1.0(0.5)1.0) xscale(range(-1.0(0.5)1.0)) title("`title'", size(medium)) 
		  	
		graph save balance`i', replace
		  
	}			  
				  
				  
** Combine all graphs
		 
		gr combine balance1.gph balance2.gph balance3.gph balance4.gph balance5.gph balance6.gph balance7.gph balance8.gph balance9.gph balance10.gph balance11.gph balance12.gph balance13.gph balance14.gph balance15.gph balance16.gph balance17.gph,  graphregion(color(white))
		
*** Export graph
	*graph export "${graphdir}/balance_by_protest.eps", as(eps) preview(off) replace
	
	
	
************************************************************************************
*** Supplementary Fig. 5b: Balancing by protest with entropy balancing weights	 *** 
************************************************************************************

	use `temp', clear
	
*** Generate entropy balancing weights per protest, merge protests back into one file

	foreach v in age sex education size_hh status_employment teen_14_18_hh labour_income {
		replace `v' = . if `v'_missing == 1
	} // to only balance on nonmissing observations


	tempfile ebal
	save `ebal'

** Entropy balancing
	foreach i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 {
	use `ebal', clear
	keep if event_id == `i'
	   ebalance post_all age sex education size_hh status_employment teen_14_18_hh labour_income, tar(1)
		tempfile p`i'
		save `p`i''
	}
	


	use `p17', clear
	append using `p1' 	
	append using `p2' 
	append using `p3' 
	append using `p4' 
	append using `p5' 
	append using `p6' 
	append using `p7' 
	append using `p8' 
	append using `p9' 
	append using `p10' 
	append using `p11' 
	append using `p12' 
	append using `p13' 
	append using `p14' 
	append using `p15' 
	append using `p16' 
	
	*Check correct number of observations
	sum _webal
		
	foreach v in age sex education size_hh status_employment teen_14_18_hh labour_income{
		replace `v' = 0 if `v'_missing == 1
	}
	
	
	
	tempfile temp 
	save `temp'
	
*** Run balancing table for protests without y-axis

	*Global sample size by protest with ebalance
	local sample_sizes "2,601 724 165 353 362 5,327 2,174 1,466 609 355 201 2,556 3,538 608 573 752 630"

	foreach i in  2 3 4 5  7 8 9 10  12  13 14 15  17   {
	
	// Individual loop for each protest ID with the corresponding sample size
	local samplesize_ebal : word `i' of `sample_sizes'
    local title "Protest `i' (N=`samplesize_ebal')"

	use `temp', clear
	
	** Keep only respective protest
	keep if event_id == `i'

*** Balance table standardized
	reg zage post_`i'  if age_missing == 0 [aw=_webal], r
		eststo balance_1
	reg zsex post_`i'   if sex_missing == 0 [aw=_webal], r
		eststo balance_2
	reg zsize_hh post_`i'   if size_hh_missing == 0 [aw=_webal], r
		eststo balance_3
	reg zeducation post_`i'   if education_missing == 0 [aw=_webal], r
		eststo balance_4
	reg zstatus_employment post_`i'   if status_employment_missing == 0 [aw=_webal], r
		eststo balance_5
	reg zteen_14_18_hh post_`i'   if teen_14_18_hh_missing == 0 [aw=_webal], r
		eststo balance_6
	reg zlabour_income post_`i'   if labour_income_missing == 0 [aw=_webal], r
		eststo balance_7
	reg zstrong_interest_politics post_`i'   if strong_interest_politics_missing == 0 [aw=_webal], r
		eststo balance_8
	reg zcat_pol_orient post_`i'   if cat_pol_orient_missing == 0 [aw=_webal], r
		eststo balance_9
		
	** Create coefplot
		coefplot ///
                   balance_1, bylabel(" ") ||  ///
                   balance_2, bylabel(" ") || ///
                   balance_3, bylabel(" ") || ///
                   balance_4, bylabel(" ") || ///
                   balance_5, bylabel(" ") || ///
                   balance_6, bylabel(" ") || ///
                   balance_7, bylabel(" ") || ///
                   balance_8, bylabel(" ") || ///
                   balance_9, bylabel(" ") || ///
          , keep(post_1 post_2 post_3 post_4 post_5 post_6 post_7 post_8 post_9 post_10 post_11 post_12 post_13 post_14 post_15 post_16 post_17) xline(0, lc(cranberry))  grid(none) ///
          bycoefs horizontal subtitle(, bcolor(white))  scheme(lean2) color(navy) ciopts(lc(navy) recast(rcap) lwidth(thin) msize(small)) graphregion(color(white)) ///
		  byopts(graphregion(col(white)) rows(5) bgcol(white)) xlabel(-1.0(0.5)1.0) xscale(range(-1.0(0.5)1.0))  title("`title'", size(medium))
		  	
		graph save balance`i', replace  
	}
	
*** Run balancing table for protests with y-axis

	
	use `temp', clear

	foreach i in 1 6 11 16{
	
	// Individual loop for each protest ID with the corresponding sample size
	local samplesize_ebal : word `i' of `sample_sizes'
    local title "Protest `i' (N=`samplesize_ebal')"

	use `temp', clear
	
	*** Keep only respective protests
	keep if event_id == `i'

**Balance table standardized
	reg zage post_`i'  if age_missing == 0 [aw=_webal], r
		eststo balance_1
	reg zsex post_`i'   if sex_missing == 0 [aw=_webal], r
		eststo balance_2
	reg zsize_hh post_`i'   if size_hh_missing == 0 [aw=_webal], r
		eststo balance_3
	reg zeducation post_`i'   if education_missing == 0 [aw=_webal], r
		eststo balance_4
	reg zstatus_employment post_`i'   if status_employment_missing == 0 [aw=_webal], r
		eststo balance_5
	reg zteen_14_18_hh post_`i'   if teen_14_18_hh_missing == 0 [aw=_webal], r
		eststo balance_6
	reg zlabour_income post_`i'   if labour_income_missing == 0 [aw=_webal], r
		eststo balance_7
	reg zstrong_interest_politics post_`i'   if strong_interest_politics_missing == 0 [aw=_webal], r
		eststo balance_8
	reg zcat_pol_orient post_`i'   if cat_pol_orient_missing == 0 [aw=_webal], r
		eststo balance_9

	** Create coefplot
		coefplot ///
                   balance_1, bylabel("Age") ||  ///
                   balance_2, bylabel("Sex") || ///
                   balance_3, bylabel("HH size") || ///
                   balance_4, bylabel("Educ") || ///
                   balance_5, bylabel("STE") || ///
                   balance_6, bylabel("Teens") || ///
                   balance_7, bylabel("Income") || ///
                   balance_8, bylabel("Int Pol") || ///
                   balance_9, bylabel("Pol Or") || ///
          , keep(post_1 post_2 post_3 post_4 post_5 post_6 post_7 post_8 post_9 post_10 post_11 post_12 post_13 post_14 post_15 post_16 post_17) xline(0, lc(cranberry))  grid(none) ///
          bycoefs horizontal subtitle(, bcolor(white))  scheme(lean2) color(navy) ciopts(lc(navy) recast(rcap) lwidth(thin) msize(small)) graphregion(color(white)) ///
		  byopts(graphregion(col(white)) rows(5) bgcol(white)) xlabel(-1.0(0.5)1.0) xscale(range(-1.0(0.5)1.0))  title("`title'", size(medium))
		  	
		graph save balance`i', replace	  
	}
				  
				  
				  
** Combine graphs
		 
		gr combine balance1.gph balance2.gph balance3.gph balance4.gph balance5.gph balance6.gph balance7.gph balance8.gph balance9.gph balance10.gph balance11.gph balance12.gph balance13.gph balance14.gph balance15.gph balance16.gph balance17.gph,  graphregion(color(white))
		
*** Export graph
	graph export "${graphdir}/ebalance_by_protest.eps", as(eps) preview(off) replace
	



