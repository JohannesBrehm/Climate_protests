/******************************************************************************* 	
*	Replication files: Climate protests increase concerns about climate change *
********************************************************************************
*											 					               *
*	PURPOSE: Fig. 1b – Climate change concerns in Germany and Google Trends of protest movements * 
*					   										                   *
*******************************************************************************/

*** Standard settings go here
	clear all
	set more off

****************************************************************************************
*	Fig. 1b – Climate change concerns in Germany and Google Trends of protest movements*
*************************************************************************************** 

*** Load data
	use "${datadir}\SOEP\soep_working_data.dta", clear
	
*** Restrict survey data to protest time window
	drop if year <= 2015

*** Mirror concern aggregation like in the analysis
	gen high_climate_concern = .
		replace high_climate_concern = 1 if plh0037 == 1
		replace high_climate_concern = 0 if plh0037 == 2
		replace high_climate_concern = 0 if plh0037 == 3

	gen agg_climate_concern = .
		replace agg_climate_concern = 1 if plh0037 == 1
		replace agg_climate_concern = 1 if plh0037 == 2
		replace agg_climate_concern = 0 if plh0037 == 3
	
*** Weekly means
	gen auxdate = mdy(month, day, year)
	format auxdate %td
	gen week = yw(year(auxdate), week(auxdate))
	format week %tw
	
	bysort week : egen agg_climate_concern_week = mean(agg_climate_concern)

*** Count surveys conducted per week
	egen week_count = count(week), by(week)
	
*** Compress to one observation per week (mean value)
	duplicates drop week agg_climate_concern_week, force
	
*** Delete one scarp observation from year change
	drop if week == .
	
*** Generate new observation for missing week (no interview conducted but important for continuous time series)
	set obs `=_N+1'
		replace week = 2915 if week_count == .

*** Add one observation to include 2021 as label in plot
	set obs `=_N+1'
		replace week = 3172 if week == .
		
	sort week

*** Translate into percentages
	replace agg_climate_concern_week = agg_climate_concern_week * 100
		
*** Keep only relevant variables
	keep auxdate week agg_climate_concern_week week_count

*** save to produce plot in R, continue with R.file
	save "${datadir}\SOEP\r_input_fig1b.dta", replace

	