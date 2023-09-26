**Replication guide „Climate protests increase concerns about climate change”**

**Data**


The research reported in the article „Climate protests increase concerns about climate change” uses data from the German Socio-Economic Panel Study. Due to data protection regulations, the data cannot be made publicly available, however, the data are available for scientific research free of charge and any researcher can apply for access of the data. Please contact the SOEP department at DIW Berlin via soepmail@diw.de for enquiries.
The results reported in the article and the supplementary material can be replicated using the raw data provided by DIW Berlin, once a data access agreement has been signed. The article used v37 of the data, DOI: 10.5684/soep.core.v37eu.
The replication package also contains data which is merged to the SOEP. The folder “data” contains the following files: 
-	protest_database.xlsx contains information to the salient protests selected for analysis (e.g., a link to the Tagesschau or ZDFheute archive)
-	protests_germany.xlsx/protests_germany.dta contains the protest data in a simple format that is merged with the SOEP
-	r_input_fig1b.dta contains the data needed to replicate Fig. 1b in R
-	election_cop.xlsx/election_cop.dta contains the dates for the control variables for federal election dates as well as UN COPs
-	google_trends_fff_eg_xr.dta contains the weekly Google Trends from 2006 to 2020 needed to replicate parts of Fig. 1b
-	weekday.xlsx/weekday.dta contains for each date the corresponding weekday needed for the weekday fixed effect
-	XR.docx, FfF.docx and EG.docx contain all the newspaper headings from Factiva needed to replicate Supplementary Fig. 1
-	The folder weather contains all the weather data used in the analysis
  
**Software and System Requirements**


The research was conducted using Stata version 16.1 MP 64 and R version 4.3.1 for Windows.
We used the following packages in Stata: 
-	reghdfe, ebalance, estout, coefplot, mlogit, gologit2
We used the following packages in R: 
-	haven, ggplot2, patchwork, lubridate, readtext, dplyr, gridExtra
Installation guide
-	For Stata, the packages can be installed via - ssc install package_name – 
-	For R, the required packages can be installed via install.packages(‘package_name’) and then library(‘package_name’)
-	Each package should install in less than a minute on a 4-core Intel-based laptop with Windows 11 version 22H2

**Instructions for use**


The replication package includes four folders: code, data, results. Code contains the do-files for Stata and R-Scripts necessary to clean the data and obtain the results and figures. 
1.	Open the do-file “00_master.do”. At the beginning of the file, there are four global macros defined. These contain the file paths for main directory of the replication package, the raw data, the folder with the do-files, and the folder in which the output will be written. These four file paths need to be adjusted accordingly. 
2.	“01_preparing_SOEP.do“ draws the relevant variables from the SOEP. “02_preparing_data.do” merges the protest data and other data sets with the SOEP data and creates new variables. 
3.	The remaining do-files and R-Scripts replicate the results and figures. The file names contain a number “0X_” according to the order in the manuscript. Moreover, the do-file name contains a pointer to the section (e.g., “_main” or “_sup_mat” for Supplementary Material). Lastly, it contains a short description of the main content (e.g., “_main_results”). 
4.	For the R-Scripts, you need to enter your working directory and file path (“PUT YOUR PATH HERE”) before loading the data or exporting the results. 

