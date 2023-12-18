/******************************************************************************* 	
*	Replication files: Climate protests increase concerns about climate change *
********************************************************************************
*											 					               *
*	PURPOSE: Fig. XX: Heterogeneous treatment effects (LMP, Colum (6))		   *
*																			   *					
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
	
************************************************************************************
*	Fig. 2c: Heterogeneous treatment effects (LMP, Colum (6))			   		   * 
************************************************************************************

*** Heterogeneities


		
** 1) Age
		replace age = . if age_missing == 1
		egen median_age = median(age)
		
	
		gen old = . 
		replace old = 0 if age <=median_age  &  age !=.
		replace old = 1 if age > median_age &  age !=.
		
		gen young = . 
		replace young = 1 if age <= median_age & age !=.
		replace young = 0 if age >median_age &  age !=.
		
		replace age = 0 if age_missing == 1
		
		foreach var of varlist old young {
		gen `var'_post = `var' * post_all
		}
		

		
	** Regression
		reghdfe agg_climate_concern post_all##young $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 
		eststo heter_age
		
*** 2) Sex

		gen female = . 
		replace female = 1 if sex == 2
		replace female = 0 if sex == 1

		gen male = . 
		replace male = 0 if sex == 2
		replace male = 1 if sex == 1
		
		foreach var of varlist female male {
		gen `var'_post = `var' * post_all
		}
		
	** Regression 
		reghdfe agg_climate_concern post_all##male $X $weather $interview_X i.election_cop, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 
		eststo heter_sex
						
*** 3) Income 
	
	*generate median income 
		replace labour_income = . if labour_income_missing == 1
		egen median_labourinc = median(labour_income)
		replace labour_income = 0 if labour_income_missing == 1
		
		gen rich = . 
		replace rich = 0 if  labour_income<=median_labourinc & labour_income_missing == 0
		replace rich = 1 if  labour_income>median_labourinc & labour_income_missing == 0

		gen poor = . 
		replace poor = 1 if  labour_income<=median_labourinc & labour_income_missing == 0
		replace poor = 0 if  labour_income>median_labourinc & labour_income_missing == 0
	

		foreach var of varlist rich poor {
		gen `var'_post = `var' * post_all
		}
		
	** Regression 
		reghdfe agg_climate_concern post_all##poor $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 
		eststo heter_inc
		
		
		
*** 4) Education
	
	** Generate variables

		replace education = . if education_missing == 1
		egen median_education = median(education)
		replace education = 0 if education_missing == 1
	
		gen educ_high = .
		replace educ_high = 1 if education > median_education & education_missing == 0
		replace educ_high = 0 if education <=median_education & education_missing == 0
		
		gen educ_low = .
		replace educ_low = 0 if education >median_education & education_missing == 0
		replace educ_low = 1 if education <=median_education & education_missing == 0

		foreach var of varlist educ_high educ_low {
		gen `var'_post = `var' * post_all
		}
		
	** Regression
		reghdfe agg_climate_concern post_all##educ_low $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 
		eststo heter_educ
		
*** 5) How future is viewed/Optimism

	** Generate variables
		gen optimism = . 
		replace optimism = 1 if future_extpol <3 & future_extpol != . 
		replace optimism = 0 if future_extpol >2 & future_extpol != . 
		
		gen pessimism = . 
		replace pessimism = 0 if future_extpol <3 & future_extpol != . 
		replace pessimism = 1 if future_extpol >2 & future_extpol != . 

		foreach var of varlist optimism pessimism {
		  gen `var'_post = `var' * post_all
		  }
   
	** Regression
		reghdfe agg_climate_concern post_all##pessimism $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 
		eststo heter_future

		
*** 6) Political orientation
	
	** Generate variables	
		foreach var of varlist right center left {
		gen `var'_post = `var' * post_all
		}
		
	** Regression
		reghdfe agg_climate_concern post_all##center post_all##left $X $weather i.election_cop $interview_X, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 
		eststo heter_politics
		


*** 7) Interest in politics

	** Generate variables
		replace interest_politics = . if interest_politics < 0 // if no answer or not in questionnaire
				
		gen polint = . 
		replace polint = 1 if interest_politics <3 & interest_politics!=.
		replace polint = 0 if interest_politics >2 & interest_politics!=.
		
		gen no_polint = . 
		replace no_polint = 0 if interest_politics <3 & interest_politics!=.
		replace no_polint = 1 if interest_politics >2 & interest_politics!=.

		foreach var of varlist polint no_polint {
		gen `var'_post = `var' * post_all
		}
   
   
   
   
   
	** Regresssions
		reghdfe agg_climate_concern post_all##no_polint $X $weather i.election_cop, a($delta i.event_id i.l11101 i.year i.month weekday)  cluster(i.event_id) 
		eststo heter_polint
		
	*** Output table
	estout heter_age heter_sex heter_inc heter_educ heter_future heter_politics heter_polint using  "${graphdir}\table_heterogeneity.tex", ///
                                style(tex) cells(b(star fmt(4)) se(par fmt(4)) p(par([ ])))  posthead() ///
                starlevels( * 0.1 ** 0.05 *** 0.01)   ///
                stats(N, layout(@ @) labels("Number of observations"))  mlabels(none)   ///
                collabels(none) eql(none) notype label postfoot( \addlinespace) replace        
    eststo clear
	