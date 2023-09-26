/******************************************************************************* 	
*	Replication files: Climate protests increase concerns about climate change *
********************************************************************************
*											 					               *
*	PURPOSE: 	Master do-files												   *
*					   										                   *
*											 					               *
*   OUTLINE:  	PART 1: Set user and paths for analysis					 	   *
*		   		PART 2: Run analyses		                                   *
*																			  *									
*******************************************************************************/


********************************************************************************
*	PART 1:  Set paths						                                   *
********************************************************************************

*** Standard settings go here
	clear all
	set more off

********************************************************************************
*	PART 1:  Set user and paths for analysis				                   *
********************************************************************************

**Set the user
local user=1
	
	** User 1
	else if `user'==1	{
	global maindir "set path to main folder"
	global datadir "${maindir}/data"
	global graphdir "${maindir}/figures"
	global dodir	"${maindir}/code"

						}
	
	** User 2
	else if `user'==2	{
	global maindir "set path to main folder"
	global datadir "${maindir}/data"
	global graphdir "${maindir}/figures"
	global dodir	"${maindir}/code"
					}
						
				
********************************************************************************
*	PART 2:  Run analyses					                                   *
********************************************************************************

*** Preparing SOEP data
	do "$dodir/01_preparing_SOEP.do"
	
*** Generating variables and data cleaning
	do "$dodir/02_preparation_data.do"
	
*** Prepare data for Fig. 1b, run ananlysis in R with R-Script labelled "03_main_fig_1b"
	do "$dodir/03_main_fig_1b.do"
	
*** Run main analysis, Fig. 2a
	do "$dodir/04_main_fig_2a_main_results.do"

*** Run analysis by pre-protest concern level, Fig. 2b
	do "$dodir/05_main_fig_2b_pre_protest.do"

*** Run analysis for heterogeneities, Fig. 2c
	do "$dodir/06_main_fig_2c_heterogeneities.do"

*** Run R-Script "07_sup_mat_fig_1_newspaper_articles" to replicate Supplementary Fig. 1

*** Run analysis for Supplementary Tab. 1 – Balance Test Treatment and Control Group
	do "$dodir/08_sup_mat_tab_1_balance_agg.do"

*** Run analysis for Supplementary Fig. 3 – Treatment effects over time
	do "$dodir/09_sup_mat_fig_3_event_study.do"

*** Run analysis for Supplementary Tab. 2 – Placebo results
	do "$dodir/10_sup_mat_tab_2_placebo.do"

*** Run analysis for Supplementary Tab. 3 – Average marginal effects wrt pre-protest population concern levels.
	do "$dodir/11_sup_mat_tab_3_marginal_preprotest.do"

*** Run analysis for Supplementary Fig. 4 – Treatment effects for alternative time windows 
	do "$dodir/12_sup_mat_fig_4_time_windows.do"

*** Run analysis for Supplementary Fig. 5 – Iteratively excluding climate protests
	do "$dodir/13_sup_mat_fig_5_excluding_protests.do"

*** Run analysis for Supplementary Tab. 4 – Excluding double protests
	do "$dodir/14_sup_mat_tab_4_exl_double_protests.do"
	
*** Run analysis for Supplementary Fig. 6 - Balance by protest
	do "$dodir/15_sup_mat_fig_6_balance_by_protest.do"

*** Run analysis for Supplementary Tab. 5 - Placebo by protest	
	do "$dodir/16_sup_mat_tab_5_placebo_by_protest.do"

*** Run analysis for Supplementary Fig. 7 - Main results by individual climate protest
	do "$dodir/17_sup_mat_fig_7_results_by_protests.do"

*** Run analysis for Supplementar Fig. 8:  Effects by dominant protest strategy	
	do "$dodir/18_sup_mat_fig_8_type_protest.do"

*** Run analysis for Supplementary Tab. 6 – Intensive margin
	do "$dodir/19_sup_mat_tab_6_intensiv_margin.do"

*** Run analysis for Supplementary Tab. 7 - Secondary outcome: concern envir. protection	
	do "$dodir/20_sup_mat_tab_7_secondary_outcome.do"

*** Run analysis for correlations used in the manuscript	
	do "$dodir/21_correlations.do"				