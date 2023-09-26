/******************************************************************************* 	
*	Replication files: Climate protests increase concerns about climate change *
********************************************************************************
*											 					               *
*	PURPOSE: 	Prepare the SOEP for analysis								   *
*					   										                   *
*											 					               *
*   OUTLINE:  	PART 1:	SOEP data - outcome variable 			   	           *
*		   		PART 2: SOEP data - control variables	                       *
*				PART 3: SOEP data - merge different SOEP data                  *
*		   		PART 4:  SOEP data - interviewer control variables    	       *
*											 					               *
*******************************************************************************/

*** Standard settings go here
	clear all
	set more off

********************************************************************************
*	PART 1:  SOEP data - outcome and control variables                         *
********************************************************************************

*Load SOEP_v37
use "M:\SOEP\SOEP_v37\SOEP-LONG_v37\pl.dta" , clear

*** drop observations with missing date
	replace ptagin = . if ptagin <= 0
	replace pmonin = . if pmonin < 0

*** keep only variables that we need for analysis (covariates are adjusted in 02_preparing_data)
	keep pid hid intid syear pmonin ptagin  plh0027-plh0043 plh0037  plh0111 plh0007 plh0033 plh0038 plh0040 plj0046 plj0047 plh0032 plh0042 plh0335 plh0004 plh0333 plm0564 plh0188 plh0244 plh0054 plh0056 plh0061 plh0192 plh0392 plh0012_v6 plh0377_v2

*** rename time variables 
	rename syear year 
	rename pmonin month
	rename ptagin day

*** Drop earlier years not in analysis
	drop if year <= 2013

*** Save dataset
save "${datadir}\soep_initial.dta", replace


********************************************************************************
*	PART 2:  SOEP data - other control variables                               *
********************************************************************************

*** GENERAL COVARIATES

use "M:\SOEP\SOEP_v37\SOEP-LONG_v37\pequiv.dta" ,clear

*** rename time variables 
	rename syear year 

*** keepo only relevant variables (covariates are adjusted in 02_preparing_data)
	keep pid hid year d11101 d11102ll d11106 d11107 d11109 e11102 e11106 e11107 h11102 i11102 l11102 l11101 i11102 i11103 e11106 e11105_v1

*** Save
	save "${datadir}\SOEP_covariates.dta", replace


	
********************************************************************************
*	PART 3:  merge different SOEP data                              		   *
********************************************************************************
	
	use "${datadir}/SOEP_covariates.dta", clear	
		
	
*** merge with outcome variable data
	merge 1:1 pid hid year using "${datadir}/soep_initial.dta", gen(merge_check)

	drop if merge_check == 1 // we keep the few non-matches in the using data since they still have potentially relevant information in the outcome variable and we will account for the not added covariates in the regressions
	drop merge_check 


	
********************************************************************************
*	PART 4:  SOEP data - interviewer control variables     				       *
********************************************************************************	


*** INTERVIEWER CHARACTERISTICS COVARIATES

	tempfile interviewer
	save `interviewer'

use "M:\SOEP\SOEP_v37\SOEP-LONG_v37\interviewer.dta" ,clear

*** rename time variables 
	rename syear year 

*** keepo only relevant variables (year, interviewer id, gender, birth year, education core information and questionnaire, and climate change consequences concern) 
	keep year intid gender  birth educ_c  isor12

*** prepare variables
	tab gender
	rename gender gender_int
	gen gender_int_missing = 0 
	replace gender_int_missing = 1 if gender_int == -1

	tab educ_c
	rename educ_c educ_int
	gen educ_int_missing = 0 
	replace educ_int_missing = 1 if educ_int < 0

	tab birth
	rename birth birth_int
	gen birth_int_missing = 0 
	replace birth_int_missing = 1 if birth_int == -1

	tab isor12
	rename isor12 clconcern_int
	gen clconcern_int_missing = 0 
	replace clconcern_int_missing = 1 if clconcern_int < 0 // many missings 


*** merge
	merge 1:m intid year using `interviewer', gen(merge_check)

	drop if merge_check == 1 // also many non-matches in using. Therefore have to adjust missing values in variable later
	drop merge_check 

	replace educ_int_missing = 1 if missing(educ_int)
	replace gender_int_missing = 1 if missing(gender_int)
	replace birth_int_missing = 1 if missing(birth_int)
	replace clconcern_int_missing = 1 if missing(clconcern_int)

	replace educ_int = -1 if missing(educ_int)
	replace gender_int = -1 if missing(gender_int)
	replace birth_int = -1 if missing(birth_int)
	replace clconcern_int = -1 if missing(clconcern_int)

	
*** Save working data 
	save "${datadir}/soep_working_data.dta", replace


