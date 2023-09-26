/******************************************************************************* 	
*	Replication files: Climate protests increase concerns about climate change *
********************************************************************************
*											 					               *
*   OUTLINE:  	PART 1:  Merge protest data to SOEP data					   *
*		   		PART 2:  Prepare weather variables			                   *                
*				PART 3:  Weekdays											   *			   		
*				PART 4:  Covariates: Elections and COPs						   *
*				PART 5:  Generation/cleaning of variables					   *
*											 					               *
*******************************************************************************/

*** Standard settings go here
	clear all
	set more off

********************************************************************************
*	PART 1:  Merge protest data to SOEP data						           *
********************************************************************************

*** Merge protest data

*** Import protest data
	use "${datadir}\protests_germany.dta", clear 

*** Merge to SOEP data on year-month-day basis
	merge 1:m year month day using "${datadir}\soep_working_data.dta", gen(merge_check)
	drop merge_check // keep non-merges since they have valuable information >> marches but no interviews on that specific date (usually weekend)

*** Rename variable
	rename no_strikes number_strikes

*** Since missing information for some years: interpolate state information from previous years
	bysort hid: egen state_new = median(l11101)
	replace l11101 = state_new if missing(l11101)
	drop state_new

*** Aggregate smaller city-states to larger federal states around them to avoid too restrictive state FEs.
	clonevar state_agg = l11101
	recode state_agg (2=1) // HH = Schleswig Holstein
	recode state_agg (4=3) //  Bremen = Lower Sachsony
	recode state_agg (11=12) // Berlin == Brandenburg


********************************************************************************
*	PART 2:  Prepare weather variables				                       *
********************************************************************************

*** Prepare and merge weather information for the federal states

*** precipitation
*****************

	tempfile weather 
	save `weather'

	** Hamburg
	use "${datadir}\weather\precipitation_monthly.dta", clear 
	keep if l11101 == 3
	replace l11101 = 2

	foreach var in precipitation hist_mean_prec hist_mean_prec_deviation hist_mean_prec_deviation_qu {
		gen `var'_h = `var'
	}
	drop precipitation hist_mean_prec hist_mean_prec_deviation hist_mean_prec_deviation_qu

	tempfile hamburg
	save `hamburg'

	** Berlin
	use "${datadir}\weather\precipitation_monthly.dta", clear 
	keep if l11101 == 12
	replace l11101 = 11

	foreach var in precipitation hist_mean_prec hist_mean_prec_deviation hist_mean_prec_deviation_qu {
		gen `var'_b = `var'
	}
	drop precipitation hist_mean_prec hist_mean_prec_deviation hist_mean_prec_deviation_qu

	tempfile berlin
	save `berlin'

	** Bremen
	use "${datadir}\weather\precipitation_monthly.dta", clear 
	keep if l11101 == 3
	replace l11101 = 4

	foreach var in precipitation hist_mean_prec hist_mean_prec_deviation hist_mean_prec_deviation_qu {
		gen `var'_br = `var'
	}
	drop precipitation hist_mean_prec hist_mean_prec_deviation hist_mean_prec_deviation_qu

	tempfile bremen
	save `bremen'

	** merge 
	use `weather', clear 

	merge m:1 year month l11101 using "${datadir}\weather\precipitation_monthly.dta", gen(merge_check)
	drop if merge_check == 2
	drop merge_check 

	merge m:1 year month l11101 using `hamburg', gen(merge_check)
	drop if merge_check == 2
	drop merge_check 

	merge m:1 year month l11101 using `berlin', gen(merge_check)
	drop if merge_check == 2
	drop merge_check 

	merge m:1 year month l11101 using `bremen', gen(merge_check)
	drop if merge_check == 2
	drop merge_check 


	foreach var in precipitation hist_mean_prec hist_mean_prec_deviation hist_mean_prec_deviation_qu {
		replace `var' = `var'_h if missing(`var')
		replace `var' = `var'_b if missing(`var')
		replace `var' = `var'_br if missing(`var')
	}


*** temperature
***************

	tempfile weather 
	save `weather'


	** Hamburg
	use "${datadir}\weather\temperature_monthly.dta", clear 
	keep if l11101 == 3
	replace l11101 = 2

	foreach var in temperature hist_mean_temp hist_mean_temp_deviation hist_mean_temp_deviation_qu {
		gen `var'_h = `var'
	}
	drop temperature hist_mean_temp hist_mean_temp_deviation hist_mean_temp_deviation_qu

	tempfile hamburg
	save `hamburg'

	** Berlin
	use "${datadir}\weather\temperature_monthly.dta", clear 
	keep if l11101 == 12
	replace l11101 = 11

	foreach var in temperature hist_mean_temp hist_mean_temp_deviation hist_mean_temp_deviation_qu {
		gen `var'_b = `var'
	}
	drop temperature hist_mean_temp hist_mean_temp_deviation hist_mean_temp_deviation_qu

	tempfile berlin
	save `berlin'

	** Bremen
	use "${datadir}\weather\temperature_monthly.dta", clear 
	keep if l11101 == 3
	replace l11101 = 4

	foreach var in temperature hist_mean_temp hist_mean_temp_deviation hist_mean_temp_deviation_qu {
		gen `var'_br = `var'
	}
	drop temperature hist_mean_temp hist_mean_temp_deviation hist_mean_temp_deviation_qu

	tempfile bremen
	save `bremen'

	** merge 
	use `weather', clear 

	merge m:1 year month l11101 using "${datadir}\weather\temperature_monthly.dta", gen(merge_check)
	drop if merge_check == 2
	drop merge_check 

	merge m:1 year month l11101 using `hamburg', gen(merge_check)
	drop if merge_check == 2
	drop merge_check 

	merge m:1 year month l11101 using `berlin', gen(merge_check)
	drop if merge_check == 2
	drop merge_check 

	merge m:1 year month l11101 using `bremen', gen(merge_check)
	drop if merge_check == 2
	drop merge_check 


	foreach var in temperature hist_mean_temp hist_mean_temp_deviation hist_mean_temp_deviation_qu {
		replace `var' = `var'_h if missing(`var')
		replace `var' = `var'_b if missing(`var')
		replace `var' = `var'_br if missing(`var')
	}

*** Drop variables not needed 
	drop precipitation_h hist_mean_prec_h hist_mean_prec_deviation_h hist_mean_prec_deviation_qu_h precipitation_b hist_mean_prec_b hist_mean_prec_deviation_b hist_mean_prec_deviation_qu_b precipitation_br hist_mean_prec_br hist_mean_prec_deviation_br hist_mean_prec_deviation_qu_br temperature_h hist_mean_temp_h hist_mean_temp_deviation_h hist_mean_temp_deviation_qu_h temperature_b hist_mean_temp_b hist_mean_temp_deviation_b hist_mean_temp_deviation_qu_b temperature_br hist_mean_temp_br hist_mean_temp_deviation_br hist_mean_temp_deviation_qu_br


*** time variables
	sort year month day, stable
	gen period=mdy(month, day, year)
	drop if missing(period) // drop the 2 observations on the impossible date 31 april


********************************************************************************
*	PART 3:  Weekdays				                                           *
********************************************************************************

*** Merge in information on the weekday for fixed effects later
	merge m:1 year month day using "${datadir}\weekday.dta", gen(merge_check)
	drop if merge_check == 2
	drop merge_check

********************************************************************************
*	PART 4:  Covariates: Elections and COPs				                   *
********************************************************************************

*** Merge in information on possible confounders (COPs and national elections)
	merge m:1 year month day using "${datadir}\election_cop.dta", gen(merge_check) keepusing(type_event)
	drop if merge_check == 2
	gen election_cop = 0 
	replace election_cop = 1 if merge_check == 3 //matched dates
	drop merge_check

********************************************************************************
*	PART 5:  Generation/cleaning of variables		                           *
********************************************************************************

*** Clean outcome variable 
	tab plh0037
	replace plh0037 = . if plh0037 == -5 | plh0037 == -1
	tab plh0036
	replace plh0036 = . if plh0036 == -5 | plh0037 == -1

*** Generate main outcome variable
	gen agg_climate_concern = .
	replace agg_climate_concern = 1 if plh0037 == 1
	replace agg_climate_concern = 1 if plh0037 == 2
	replace agg_climate_concern = 0 if plh0037 == 3

*** Generate high concern outcome variable
	gen high_climate_concern = .
	replace high_climate_concern = 1 if plh0037 == 1
	replace high_climate_concern = 0 if plh0037 == 2
	replace high_climate_concern = 0 if plh0037 == 3


*** Gen political attitudes (we use the data from 2014, the last year it was surveyed before the protests started, so it is not influenced by the climate protests). We keep this 2014 value fixed over time at the individual level. 
	recode plh0004 (-8=.) (-5=.) (-1=.) (0=0.5)
	
	gen pol_att_aux = plh0004 if year == 2014
	bysort pid: egen pol_att_extpol = total(pol_att_aux)
	recode pol_att_extpol (0=.) 
	recode pol_att_extpol (0.5=0) 
	la var pol_att_extpol "Political orientation 2014, 0 = hard-left 10 = hard-right"
	
*** Similarily, we use pre-protest information on the interest in politics (2015) and keep this value fixed over time at the individual level. 
	gen interest_pol_aux = plh0007 if year == 2015
	bysort pid: egen interest_pol_extpol = total(interest_pol_aux)
	recode interest_pol_extpol (0=.) (-1=.)
	la var interest_pol_extpol "Interest in politics 2015, =1 strong"
	
	gen future_aux = plh0244 if year == 2014
	bysort pid: egen future_extpol = total(future_aux)
	recode future_extpol (0=.)  (-1=.)  (-5=.)

	gen locus_aux = plh0377_v2 if year == 2015
	bysort pid: egen locus_extpol = total(locus_aux)
	recode locus_extpol (0=.)  (-1=.)  (-5=.)  (-8=.) 

*** Generate variable indicating time to treatment 
	tempfile 1
	save `1'
	duplicates drop period, force 
	sort period, stable 
	gen next_event=period if !mi(number_strikes)
	{
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 
	replace next_event = next_event[_n+1] if next_event == . 

	}

*** Make sure that no further changes are happening above
	gen previous_event=period if !mi(number_strikes)
	replace previous_event = previous_event[_n-1] if previous_event == .

*** Generate distance to next event
	gen next_event_distance = period - next_event
	gen previous_event_distance = period - previous_event
	gen e = next_event_distance if abs(next_event_distance) <= abs(previous_event_distance) // taking next event if there is a tie
	replace e = previous_event_distance if missing(e)
	keep period e next_event_distance previous_event_distance
	merge 1:m period using `1', gen(merge_check)
	drop merge_check

*** Fill in event_ids for all groups of pre and post observations
		tempfile protest_id
		save `protest_id'
		bysort period: egen protest = max(number_strikes)
		duplicates drop period, force 
		drop if missing(protest)
		sort period, stable
		gen event = .
		replace event = 1 if !mi(protest)
		gen event_id = event if _n == 1
		replace event_id = event_id[_n-1] + event if _n > 1
		replace event_id = 1 if event_id == 0
		replace event_id = . if event == 0
		keep period event_id 
		merge 1:m period using `protest_id', gen(merge_eventid)
		
		replace event_id = event_id[_n-1] if abs(next_event_distance) > abs(previous_event_distance) & event_id == .
		gsort -period
		replace event_id = event_id[_n-1] if abs(next_event_distance) <= abs(previous_event_distance) & event_id == . // when we have a tie its the next event
		sort period, stable

*** Climate change concern in 2015 
	sum agg_climate_concern if year == 2015

*** Define treatment and control group we need max. 90 days, adjust for smaller time windows in the respective analysis files separately. 
	drop if e < -90
	drop if e > 90
	
	
*** Gen var identifying protest group 
	bysort event_id: egen protest_type = mean(group_id)
	bysort event_id: egen double_protest = mean(double_event)
	sort event_id e 
	la var protest_type "=1 FFF, =2 EG, =3 XR, =4 double event"

*** Drop day of protest itself since unclear whether treated or untreated
	drop if e == 0 

	
*** Preparation Treatment
*******************************************

*** Generate indicator for post treatment 
	gen post_all = 0 
	replace post_all = 1 if e >= 0 & protest_type!=.

*** Generate fixed effects 
	egen regionXprotest = group(l11101 event_id)
	egen stateXprotest = group(state_agg event_id)
	egen eXprotest = group(e event_id)

	la var regionXprotest "Region x protest FE"
	la var stateXprotest "Federal state x protest FE"
	la var eXprotest "Event time x protest FE"


*** Preparation Covariates
*******************************************

	replace d11101 = . if d11101 == -1 //if no answer
	rename d11101 age
	
	replace d11102ll = . if d11102ll == -1 //if no answer
	rename d11102ll sex
	
	rename d11106	size_hh
	
	replace d11109 = . if d11109 == -1 //if no answer
	replace d11109 = . if d11109 == -2 // if not applicable 
	rename d11109 education
	
	replace e11102 = . if e11102 == -1 //if no answer
	rename e11102 status_employment
	
	replace e11107 = . if e11107 == -1 // if no answer
	replace e11107 = . if e11107 == -2 // if no answer
	replace e11107 = . if e11107 == 0 // not applicable 
	rename e11107 industry_employment
	
	rename h11102 teen_14_18_hh
	
	replace i11103 = . if i11103 < 0 
	rename i11103 labour_income
	
	replace plh0007 = . if plh0007 < 0 
	rename plh0007 interest_politics
	gen interest_politics_missing = 0 
	replace interest_politics_missing = 1 if interest_politics == .

	gen right = . 
	replace right = 1 if pol_att_extpol >5& pol_att_extpol!=.
	replace right = 0 if pol_att_extpol <=5& pol_att_extpol!=.

	gen left = . 
	replace left = 0 if pol_att_extpol >=5& pol_att_extpol!=.
	replace left = 1 if pol_att_extpol <5& pol_att_extpol!=.
	
	gen center = . 
	replace center = 0 if pol_att_extpol >5& pol_att_extpol!=.
	replace center = 0 if pol_att_extpol <5& pol_att_extpol!=.
	replace center = 1 if pol_att_extpol ==5& pol_att_extpol!=.
	
	gen cat_pol_orient = . 
	replace cat_pol_orient = 1 if left == 1 
	replace cat_pol_orient = 2 if center == 1 
	replace cat_pol_orient = 3 if right == 1 
	la var cat_pol_orient "=1 left, =2 center, 3=right"

	gen strong_interest_politics = . 
	replace strong_interest_politics = 0 if interest_pol_extpol>=3 & interest_pol_extpol!=.
	replace strong_interest_politics = 1 if interest_pol_extpol<=2 & interest_pol_extpol!=.

	
	*** better covariates
	sum age i.sex size_hh education i.status_employment i.industry_employment teen_14_18_hh labour_income
	
*** Replace missings with 0 to avoid losing too many observations in the analysis due to missing values

	gen age_missing = 0
	replace age_missing = 1 if missing(age)
	replace age = 0 if age_missing == 1
	
	gen sex_missing = 0
	replace sex_missing = 1 if missing(sex)
	replace sex = 0 if sex_missing == 1
	
	gen size_hh_missing = 0
	replace size_hh_missing = 1 if missing(size_hh)
	replace size_hh = 0 if size_hh_missing == 1
	
	gen teen_14_18_hh_missing = 0
	replace teen_14_18_hh_missing = 1 if missing(teen_14_18_hh)
	replace teen_14_18_hh = 0 if teen_14_18_hh_missing == 1
		
	gen status_employment_missing = 0
	replace status_employment_missing = 1 if missing(status_employment)
	replace status_employment = 0 if status_employment_missing == 1
		
	gen education_missing = 0
	replace education_missing = 1 if missing(education)
	replace education = 0 if education_missing == 1
	
	gen industry_missing = 0
	replace industry_missing = 1 if missing(industry_employment)
	replace industry_employment = 0 if industry_missing == 1
	
	gen labour_income_missing = 0
	replace labour_income_missing = 1 if missing(labour_income)
	replace labour_income = 0 if labour_income_missing == 1
	
	gen strong_interest_politics_missing = 0 
	replace strong_interest_politics_missing = 1 if missing(strong_interest_politics)
	replace strong_interest_politics = 0 if strong_interest_politics_missing == 1
	
	gen cat_pol_orient_missing = 0 
	replace cat_pol_orient_missing = 1 if missing(cat_pol_orient)
	replace cat_pol_orient = 0 if cat_pol_orient_missing == 1 
		
	gen age_int = year - birth_int
	replace age_int = 0 if birth_int_missing == 1
	gen age_int_missing = 0
	replace age_int_missing = 1 if age_int == 0

	egen weekday_numeric = group(weekday)
	
	recode plh0392 (-8=.) (-5=.) (-1=.)
	
	gen news_consumption = . 
	replace news_consumption = 1 if plh0392 ==1
	replace news_consumption = 1 if plh0392 ==2
	replace news_consumption = 1 if plh0392 ==3
	replace news_consumption = 0 if plh0392 ==4
	replace news_consumption = 0 if plh0392 ==5
	
	*** Gen protest type variable	
		gen demonstrative = . 
		replace demonstrative = 1 if protest_type == 1|protest_type ==4   // Fridays for Future or double event
		replace demonstrative = 0 if protest_type ==2|protest_type ==3
			
		gen confrontational = . 
		replace confrontational = 1 if protest_type ==2|protest_type ==3|protest_type ==4 // EG, XR or double event
		replace confrontational = 0 if protest_type ==1
			
		
***Save dataset
	save "${datadir}\working_data_complete.dta", replace 