//This program reproduces Tables 2 in the appendix, where within correlation is evaluated using firm-product-destination fixed effects.
// Table 3 evaluates adjusted within firm correlation between ranks.
* Arguments:
* - dirData: Directory for data files.
* - Includes: Directory for saving output files.
* - S: Number of simulations.
* - country: Specific country for the analysis.

args  dirData Includes S country 

// Conditional setup for China to use predefined destinations; otherwise, use dynamic destinations from data.
if "`country'"=="China"{

    local destinations "Hong-Kong, USA, Japan, Korea, Germany, UK, Taiwan, Australia, Canada, and Singapore"
	
}
else  {
    
	use exporters_at_dest.dta,clear
	
	levelsof d, local(pop_dest)
	local destinations `pop_dest'

	// Concatenate all destinations into a single string, separated by commas.
	local destinations ""
	local num_elements : word count `pop_dest'

	forvalues i = 1/`num_elements' {
		local val : word `i' of `pop_dest'
		if `i' < `num_elements' {
			local destinations "`destinations'`val', "
		}
		else {
			local destinations "`destinations'`val'"
		}
	}



}

//Data Preparation: Load and prepare the dataset for correlation analysis.
use rank_corr_data_PMC,clear

merge m:1 d using exporters_at_dest
rename v revenue
keep if rank_dest<11
keep   f hs y  vPMC* revenue  rank_dest

//Rename variables for reshaping.
forvalues i=1(1)`S'{
	rename vPMC`i' vPMC`i'_
}

reshape wide  revenue vPMC*, i(f hs y ) j(rank_dest)
capture erase temp
save temp,replace


//Correlation Analysis: Perform simple and within correlation analysis for each pair of destinations.
// In this case, within correlation is calculated using firm-fixed effects
// This block computes the correlation coefficients for product sales across different destinations.

forvalues i=1(1)10{
	local jstop= `i'
	forvalues j=1(1)`jstop'{
		
		display " i= `i' and j =`j'"
		
		use temp,clear
		
		keep if !missing(revenue`i') &!missing(revenue`j')
		keep f hs y revenue`i' vPMC*_`i'  revenue`j' vPMC*_`j' 
		
		bysort f: gen nprod=_N
		keep if nprod>1
		
		// Simple and within correlation in the data
		*simple correlation	
		egen exportrank`i' = rank(revenue`i'), by(f) field
		capture egen exportrank`j' = rank(revenue`j'), by(f) field
		
		*adjusted correalation data
		qui areg  exportrank`i' exportrank`j', absorb(f)
		local R_full=e(r2_a)
		
		qui areg  exportrank`i', absorb(f)
		local R_minus=e(r2_a)

		local adj_corr =sqrt((`R_full'-`R_minus')/(1-`R_minus'))
		
		local C`i'_`j' : di %3.2f `adj_corr'
		
		// Simple and within correlation for the simulated data
		local PMC=0
		local adj_corr=0
		forvalues k=1(1)`S'{
			
			egen rankPMC_`k'`i' = rank(vPMC`k'_`i'), by(f) field
			capture egen rankPMC_`k'`j' = rank(vPMC`k'_`j'), by(f) field
						
			* adjusted correlation
			quietly areg  rankPMC_`k'`i' rankPMC_`k'`j', absorb(f)
			local R_full=e(r2)
		
			quietly areg   rankPMC_`k'`i', absorb(f)
			local R_minus=e(r2)
			
			local adj_corr =sqrt((`R_full'-`R_minus')/(1-`R_minus'))/`S'+`adj_corr'
											
		}
		
	
			local D`i'_`j' : di %3.2f `adj_corr'
			display "D`i'_`j' =`D`i'_`j''"			
		
	}
	
}


/// Write the results in the Latex File ( the distinction in this table is that we evaluate within correlation by controlling for firm fixed effects.)

local name  "Table2-Appendix"

display "`Includes'\\`name'.tex"

file open myfile using "`Includes'\\`name'.tex", write replace
file write myfile  "\documentclass{article}" _n  ///
				    "\usepackage{threeparttable}" _n  ///
				   "\usepackage{graphicx} " _n  ///
				   "\usepackage{booktabs}" _n  ///
				   "\begin{document}" _n  ///
				   "\begin{table}[h]" _n  ///
				   "\centering" _n ///
				   "\resizebox{1\width}{!}{ " _n ///
				   "\begin{threeparttable}" _n ///
				   "\caption{Within rank correlation at 10 most popular destinations with firm fixed effects as controls (`country') \label{PairwiseACorr-PMC-selectFirst-FE}}" _n ///
				   "\begin{tabular}{lrrrrrrrrrr}" _n ///
				   "\hline" _n ///
				   "\hline" _n ///
				   "Country &\textbf{1}&\textbf{2}&\textbf{3}&\textbf{4}&\textbf{5} &\textbf{6}&\textbf{7}&\textbf{8}&\textbf{9}&\textbf{10}\\" _n ///
				   " & \multicolumn{10}{c}{Data}\\" _n ///
				   "\cmidrule{2-11}" _n ///
					"1  & $`C1_1'$    &            &            &              &            &              &             &            &                     &                     \\  "  _n ///
					"2  & $`C2_1'$    & $`C2_2'$   &            &              &            &              &             &            &                     &                     \\  "  _n ///
					"3  & $`C3_1'$    & $`C3_2'$   & $`C3_3'$   &              &            &              &  	         &            &                     &                     \\  "  _n ///
					"4  & $`C4_1'$    & $`C4_2'$   & $`C4_3'$   &  $`C4_4'$    &            &              &  	         &            &                     &                     \\  "  _n ///
					"5  & $`C5_1'$    & $`C5_2'$   & $`C5_3'$   &  $`C5_4'$    & $`C5_5'$   &              &             &            &                     &                     \\  "  _n ///
					"6  & $`C6_1'$    & $`C6_2'$   & $`C6_3'$   &  $`C6_4'$    & $`C6_5'$   &  $`C6_6'$    &  	         &            &                     &                     \\  "  _n ///
					"7  & $`C7_1'$    & $`C7_2'$   & $`C7_3'$   &  $`C7_4'$    & $`C7_5'$   &  $`C7_6'$    &  $`C7_7'$   &            &                     &                     \\  "  _n ///
					"8  & $`C8_1'$    & $`C8_2'$   & $`C8_3'$   &  $`C8_4'$    & $`C8_5'$   &  $`C8_6'$    &  $`C8_7'$   & $`C8_8'$   &                     &                     \\  "  _n ///
					"9  & $`C9_1'$    & $`C9_2'$   & $`C9_3'$   &  $`C9_4'$    & $`C9_5'$   &  $`C9_6'$    &  $`C9_7'$   & $`C9_8'$   & $`C9_9'$            &                     \\  "  _n ///
					"10 & $`C10_1'$   & $`C10_2'$  & $`C10_3'$  &  $`C10_4'$   & $`C10_5'$  &  $`C10_6'$   &  $`C10_7'$  & $`C10_8'$  & $`C10_9'$           & $`C10_10'$          \\  "  _n ///
				   "\cmidrule{2-11} " _n ///
					"& \multicolumn{10}{c}{Permuted Monte-Carlo}\\ " _n ///		
				   "\cmidrule{2-11} " _n ///	
					"1  & $`D1_1'$    &              &             &             &              &            &               &            &              &                        \\  "  _n ///
					"2  & $`D2_1'$    & $`D2_2'$     &             &             &              &            &               &            &              &                        \\  "  _n ///
					"3  & $`D3_1'$    & $`D3_2'$     & $`D3_3'$    &             &              &            &  	         &            &              &                        \\  "  _n ///
					"4  & $`D4_1'$    & $`D4_2'$     & $`D4_3'$    &  $`D4_4'$   &              &            &  	         &            &              &                        \\  "  _n ///
					"5  & $`D5_1'$    & $`D5_2'$     & $`D5_3'$    &  $`D5_4'$   & $`D5_5'$     &            &               &            &              &                        \\  "  _n ///
					"6  & $`D6_1'$    & $`D6_2'$     & $`D6_3'$    &  $`D6_4'$   & $`D6_5'$     &  $`D6_6'$  &  	         &            &              &                        \\  "  _n ///
					"7  & $`D7_1'$    & $`D7_2'$     & $`D7_3'$    &  $`D7_4'$   & $`D7_5'$     &  $`D7_6'$  &  $`D7_7'$     &            &              &                        \\  "  _n ///
					"8  & $`D8_1'$    & $`D8_2'$     & $`D8_3'$    &  $`D8_4'$   & $`D8_5'$     &  $`D8_6'$  &  $`D8_7'$     & $`D8_8'$   &              &                        \\  "  _n ///
					"9  & $`D9_1'$    & $`D9_2'$     & $`D9_3'$    &  $`D9_4'$   & $`D9_5'$     &  $`D9_6'$  &  $`D9_7'$     & $`D9_8'$   & $`D9_9'$     &                        \\  "  _n ///
					"10 & $`D10_1'$   & $`D10_2'$    & $`D10_3'$   &  $`D10_4'$  & $`D10_5'$    &  $`D10_6'$ &  $`D10_7'$    & $`D10_8'$  & $`D10_9'$    &   $`D10_10'$           \\  "  _n ///
					"\hline" _n ///
				   "\hline" _n ///
				   "\end{tabular}" _n ///
				   "\begin{tablenotes}" _n ///
				   "\small" _n ///
				    "\item  \noindent  \footnotesize{The 10 most popular destinations are `destinations'. Excludes firm-destinations pairs with only one product.}" _n ///
				   "\end{tablenotes}" _n ///
				   "\end{threeparttable}"_n ///
				   "}" _n ///
				   "\end{table}" ///
					"\end{document}" _n
file close myfile

erase "temp.dta"