{smcl}
{* *! version 0.0  29sep2021}{...}
{viewerjumpto "Syntax" "eventstudy##syntax"}{...}
{viewerjumpto "Description" "eventstudy##description"}{...}
{viewerjumpto "Options" "eventstudy##options"}{...}
{viewerjumpto "Authors" "eventstudy##authors"}{...}
{title:Title} 

{p2colset 5 19 21 2}{...}
{p2col :{hi:eventstudy} {hline 2}}
estimates and shows graphically dynamic treatment effects using event study specifications  
{p_end}
{p2colreset}{...}
 
{marker syntax}{title:Syntax}

{p 8 15 2}
{cmd:eventstudy}
{depvar} [{indepvars}] {ifin}
{cmd:,} {opth eventvariable(varname)} {opth reference(numlist)} [{help eventstudy##options:options}] {p_end}
 
 

{synoptset 26 tabbed}{...}
{synopthdr :options}
{synoptline}
{syntab :Main}
{p2coldent:* {opt eventvariable(eventvar)}}numerical variable that corresponds to the relative time to the event{p_end}
{p2coldent:* {opth reference(numlist)}}one or more relative time periods as reference categories{p_end}
{synopt :{opt cluster(clustvar)}}clusters the standard errors at the {it:clustvar}-level{p_end}
{synopt :{opth absorb(absvars)}}categorical variables that identify the fixed effects to be absorbed (for more information see {help reghdfe}){p_end}
{synopt :{opt level(#)}}set confidence level; default is {cmd:level(0.05)}{p_end}

{pstd}
{opt eventstudy} requires installing {help reghdfe} (Sergio Correia) to partial out fixed effects when absorb is used.
  
{syntab :Binning}
{synopt :{opt window_lower(real)}}earliest relative time in {it:eventvar} for which a single dummy is used for each relative time period; binning below{p_end}
{synopt :{opt window_upper(real)}}latest relative time in {it:eventvar} for which a single dummy is used for each relative time period; binning above{p_end}
{synopt :{opt keinbinning_pre}}no binning below window_lower{p_end}
{synopt :{opt keinbinning_post}}no binning above window_lower{p_end}
  
{syntab :Output}
{synopt :{opt window_lower_graph(real)}}sets left margin for the graph{p_end}
{synopt :{opt window_upper_graph(real)}}sets right margin for the graph{p_end}
{synopt :{opt gr_opts(str)}}adds options for twoway graphs (see {help twoway_options}){p_end}
{synopt :{opt scproperties(str)}}changes appearance of the scatterplot using scatter options (see {help twoway scatter}){p_end}
{synopt :{opt rcapproperties(str)}}changes appearance of the confidence intervals using rcap options (see {help twoway rcap}){p_end}
{synopt :{opt supp_reg_output}}suppresses the regression output and only showa the graph{p_end}
{synopt :{opth true(varname)}}if the true effect is known it is shown in the graph additionally to the estimated effect (for simulated data only){p_end}
{synoptline}
{p 4 6 2}* {opt eventvariable(eventvar)}} and {opth reference(numlist)}} are required.{p_end}
{p 4 6 2}the regression variables may contain {help fvvarlist:factor variables}.{p_end}
 
{marker description}{...}
{title:Description}

{pstd}
{opt eventstudy} implements a two-way fixed effects event study regression and automatically plots the corresponding event study coefficients along the event time. 
The eventstudy command may also correct for unobserved confounds as considered by Freyaldenhoven, Hansen, and Shapiro (2019). {p_end}

{marker options}{...}
{title:Options}

{marker opt_main}{...}
{dlgtab:Main}

{phang}{opt eventvariable(eventvar)} is an already centered categorial variable that contains the time relative to treatment for each individual at each calendar time. Usually the event should be at zero.
Example: If {it: year} is the time variable and {it: treatment} indicates the treatment year for each individual, then the eventvariable should be {it: eventvar}= {it: year} - {it: treatment}.

{phang}{opth reference(numlist)} sets one or more omitted categories of {it:eventvar} as reference periods. Often -1, i.e. one period before treatment, is used as the reference period.

{marker opt_binning}{...}
{dlgtab:Binning}

{phang}{opt window_lower(real)} sets the lowest relative time (left to the event), for which a single dummy variable is included. All time periods before are grouped together in one dummy variable (bin), i.e. they are binned below this lower threshold. 
For window_lower(-5) this means, that there are single dummies for periods -5, -4 , -3 and so on, but only one dummy (aggregated in -6) for all time periods before -5. If not specified, single dummies are used from the earliest time period on. 

{phang}{opt window_upper(real)} is analogous to {opt window_lower(real)}. It specifies the highest relative time (right to the event), for which a single dummy variable is included. All time periods above are binned.
For window_upper(5) this means, that there are single dummies for periods 5, 4 , 3 and so on, but only one dummy (aggregated in 6) for all time periods after 5. If not specified, single dummies are used until the last observed time period. 

{pmore}
Between {opt window_lower(real)} and {opt window_upper(real)} all time periods are included as single dummies. Outside these bounds the time periods are binned by default. If both {opt window_lower(real)} and {opt window_upper(real)} are not specified the model is perfectly saturated along the relative time periods.

{phang}{opt keinbinning_pre} ignores all time periods before {opt window_lower(real)}. Thus, there is no binning below.

{phang}{opt keinbinning_pre} ignores all time periods after {opt window_upper(real)}, such that there is no binning above.

{marker opt_output}{...}
{dlgtab:Output}

{phang}{opt window_lower_graph(real)} can be used if not all the dummies used in the regression should also be displayed in the graph. Relative time periods below {opt window_lower_graph(real)} are not shown in the graphical output.

{phang}{opt window_upper_graph(real)} is analogous to {opt window_lower_graph(real) but for the upper bound. Relative time periods above {opt window_upper_graph(real)} are not shown in the graph.

{marker references}{...}
{title:References}

{phang}
Freyaldenhoven, S., Hansen, C., and Shapiro, J. M. (2019). Pre-event trends in the panel event-study design. American Economic Review, 109(9):3307–38.
{p_end}

{marker authors}{...}
{title:Authors}

{pstd}Hendrik Schmitz{p_end}
{pstd}Matthias Westphal{p_end}
