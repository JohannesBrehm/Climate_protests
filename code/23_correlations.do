/******************************************************************************** 	
*	Replication files: Climate protests increase concerns about climate change 	*
*********************************************************************************
* 	PURPOSE: Correlations used in the manuscript								*
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
	
*** Correlations in text

*** Climate change concerns and news consumption
	pwcorr agg_climate_concern  news_consumption, sig

*** Correlation Political interest news consumption
	gen interest_pol = . 
	replace interest_pol = 1 if interest_politics == 1
	replace interest_pol = 1 if interest_politics == 2
	replace interest_pol = 0 if interest_politics == 3
	replace interest_pol = 0 if interest_politics == 4

	replace plh0377_v2 = . if plh0377_v2<0 //   Locus of Control:Beeinflussung soz. Verh. durch Engagement
	
	gen locus_control = . 
	replace locus_control = 1 if plh0377_v2 >4 & plh0377_v2!=.
	replace locus_control = 0 if plh0377_v2 <=4 & plh0377_v2!=.

** Correlation 
	pwcorr interest_pol locus_control, sig

