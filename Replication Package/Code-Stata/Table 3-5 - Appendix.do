//This program produces table 1 in the main paper

args  stataCodes Includes S country

// Load the data with product global and local rankings simulated in the data & simulated 
use rank_corr_data_PMC.dta,clear

// correlation between global and local ranks
//data
corr exportrank exportrank_gl
local d_corr : di %3.2f int(r(rho)*100)/100

//model prediction 
	local av_corr=0
	forvalues i=1(1)`S'{
		capture qui corr rankPMC`i' rank_sim_gl_`i' 
		local av_corr=r(rho)/`S'+`av_corr'
		}
	local s_corr : di %3.2f int(`av_corr'*100)/100


*****************************************************************************************************************************************
do "`stataCodes'\EvaluateExcludeRank.do"  "`S'" 
*****************************************************************************************************************************************
// Simple correlation between global ranks elsewhere and local ranks


//data
corr exportrank  rankExclude
local d_corr_else_simple : di %3.2f int(r(rho)*100)/100

//model prediction 
	local av_corr=0
	forvalues i=1(1)`S'{
		capture qui corr rankPMC`i' rankExclude`i'
		local av_corr=r(rho)/`S'+`av_corr'
		}
	local s_corr_else_simple : di %3.2f int(`av_corr'*100)/100


// correlation between global ranks elsewhere and local ranks adjusted for the number of products and destinations

* Correlation in the data - evaluated once 	
reg  exportrank rankExclude i.nprod i.ndest 
local R_full=e(r2)

reg  exportrank i.nprod i.ndest 
local R_minus=e(r2)
local adj_corr =sqrt((`R_full'-`R_minus')/(1-`R_minus'))
local d_corr_else : di %3.2f int(`adj_corr'*100)/100
display "`d_corr_else'"
		
	
* Adjusted correlation in the simulated data - evaluated S times and averaged
local av_corr=0

forvalues i=1(1)`S'{				
				qui reg  rankPMC`i' rankExclude`i' i.nprod i.ndest  
				local R_full=e(r2)
				
				qui reg  rankPMC`i' i.nprod i.ndest 
				local R_minus=e(r2)
				
				if (`R_full'>`R_minus' & `R_minus'<1){
				    local adj_corr =sqrt((`R_full'-`R_minus')/(1-`R_minus'))
				} 
				else {
				    local adj_corr=0
				}
						
				local av_corr=`adj_corr'/`S'+`av_corr'
		    }
	    
local s_corr_else : di %3.2f int(`av_corr'*100)/100

// correlation between global ranks elsewhere and local ranks adjusted for the interaction between firm and product fixed effects
generate party_origin_interact = f +"_"+ d

* Correlation in the data - evaluated once 	
areg  exportrank rankExclude, absorb(party_origin_interact)
local R_full=e(r2)

areg  exportrank, absorb(party_origin_interact)
local R_minus=e(r2)

local adj_corr =sqrt((`R_full'-`R_minus')/(1-`R_minus'))
local d_corr_else_FE: di %3.2f int(`adj_corr'*100)/100
display "`d_corr_else_FE'"
		
	
* Adjusted correlation in the simulated data - evaluated S times and averaged
local av_corr=0

forvalues i=1(1)`S'{	
				qui areg  rankPMC`i' rankExclude`i', absorb(party_origin_interact)					
				local R_full=e(r2)
				
				qui areg  rankPMC`i', absorb(party_origin_interact)					
				local R_minus=e(r2)
				
				if (`R_full'>`R_minus' & `R_minus'<1){
				    local adj_corr =sqrt((`R_full'-`R_minus')/(1-`R_minus'))
				} 
				else {
				    local adj_corr=0
				}
						
				local av_corr=`adj_corr'/`S'+`av_corr'
		    }
	    
local s_corr_else_FE : di %3.2f int(`av_corr'*100)/100

* Writing the results to a LaTeX table

local name  "Table 3-5 - Appendix"

display "`country'"
display "`name'"
display "`Includes'\\`name'.tex"

file open myfile using "`Includes'\\`name'.tex", write replace
file write myfile  "\documentclass{article}" _n  ///
				   "\usepackage{threeparttable}" _n  ///
				   "\usepackage{graphicx} " _n  ///
				   "\usepackage{booktabs}" _n  ///	
				   "\usepackage{caption}" _n  ///
				   "\begin{document}" _n  ///
				   "\begin{table}[h]" _n  ///
				   "\begin{threeparttable}" _n  ///
				   "\captionsetup{width=0.9\textwidth} % Adjust caption width" _n  ///
				   "\caption{Full Sample Correlation between Global and Local Rankings. (`country')  \label{FS_correlation}}" _n  ///
				   "\begin{tabular}{cl} \hline\hline" _n  ///
                   "             &    Correlation \\\cmidrule{1-2}% " _n  ///
				   " Data        &    `d_corr' \\" _n  ///
					" Model       &    `s_corr' \\" _n  ///
					"\hline\hline" _n  ///
					"\end{tabular}" _n  ///
					"\end{threeparttable}" _n  ///
					"\end{table}"  _n ///
					"               "_n ///
					"\begin{table}[h]" _n  ///
				    "\begin{threeparttable}" _n  ///
					"\captionsetup{width=0.9\textwidth} % Adjust caption width" _n  ///
					"\caption{Full Sample Correlation between Global Ranks Elsewhere  and Local Rankings Adjusted for the Number of Products and Destinations per Product. (`country')  \label{FS_correlation}}" _n  ///
					"\begin{tabular}{cl} \hline\hline" _n  ///
                    "             &    Correlation \\\cmidrule{1-2}% " _n  ///
					" Data        &    `d_corr_else' \\" _n  ///
					" Model       &    `s_corr_else' \\" _n  ///
					"\hline\hline" _n  ///
					"\end{tabular}" _n  ///
					"\end{threeparttable}" _n  ///
					"\end{table}"  _n ///
					"               "_n ///
					"\begin{table}[h]" _n  ///
				    "\begin{threeparttable}" _n  ///
					"\captionsetup{width=0.9\textwidth} " _n  ///
					"\caption{Full Sample Correlation between Global Ranks Elsewhere  and Local Rankings Adjusted for the Interaction between Firm and Destination Fixed Effects. (`country')  \label{FS_correlation}}" _n  ///
					"\begin{tabular}{cl} \hline\hline" _n  ///
                    "             &    Correlation \\\cmidrule{1-2}% " _n  ///
					" Data        &    `d_corr_else_FE' \\" _n  ///
					" Model       &    `s_corr_else_FE' \\" _n  ///
					"\hline\hline" _n  ///
					"\end{tabular}" _n  ///
					"\end{threeparttable}" _n  ///
					"\end{table}"  _n ///
					"               "_n ///
					"\begin{table}[h]" _n  ///
				    "\begin{threeparttable}" _n  ///
					"\captionsetup{width=0.9\textwidth} " _n  ///
					"\caption{Full Sample Simple Correlation between Global Ranks Elsewhere  and Local Rankings. (`country')  \label{FS_correlation}}" _n  ///
					"\end{document}" _n
file close myfile

