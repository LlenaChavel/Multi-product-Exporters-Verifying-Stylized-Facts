//This program reproduces Tables 2 and 3. Table 2 evaluates simple pairwise correlation between product ranks at a pair of destinations. 
// Table 3 evaluates adjusted within firm correlation between ranks.
* Arguments:
* - dirData: Directory for data files.
* - Includes: Directory for saving output files.
* - S: Number of simulations.
* - country: Specific country for the analysis.
args   dirData Includes S country


// Conditional setup for China to use predefined destinations; otherwise, use dynamic destinations from data.
if "`country'"=="China"{
    local destinations "Hong-Kong, USA, Japan, Korea, Germany, UK, Taiwan, Australia, Canada, and Singapore"
}
else {
	use exporters_at_dest.dta,clear
	
	levelsof d, local(pop_dest)
	local destinations `pop_dest'

	local destinations ""
	
	// Concatenate all destinations into a single string, separated by commas.
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

//Evaluate simple and within correlation 
* Data Preparation: Load and prepare the dataset for correlation analysis.
use rank_corr_data_PMC,clear
merge m:1 d using exporters_at_dest
rename v revenue
keep if rank_dest<11
keep   f hs y  vPMC* revenue  rank_dest


* Rename variables for reshaping.
forvalues i=1(1)`S'{
	rename vPMC`i' vPMC`i'_
}

reshape wide  revenue vPMC*, i(f hs y ) j(rank_dest)
capture erase temp
save temp,replace

* Correlation Analysis: Perform simple and within correlation analysis for each pair of destinations.
* This block computes the correlation coefficients for product sales across different destinations.
forvalues i=1(1)10{
	local jstop= `i'
	forvalues j=1(1)`jstop'{
		display " i= `i' and j =`j'"
		
		use temp,clear
		
		keep if !missing(revenue`i') &!missing(revenue`j')
		keep f hs y revenue`i' vPMC*_`i'   revenue`j' vPMC*_`j' 
		
		capture bysort f: gen nprod=_N
		capture keep if nprod>1

		// count observations per variable
		if _N>0{
		    bysort nprod: gen dummiesTMP =_n
			replace dummiesTMP = 0 if dummiesTMP>1
		
			egen dummies = total(dummiesTMP)
			local vars = dummies[1]+1
			local opv = _N/`vars'	
		}
		else {
		    local opv = 0
		}
		display "`opv'"
		 if `opv'>20{
		     
		    
			// Simple and within correlation in the data
			*simple correlation	
			egen exportrank`i' = rank(revenue`i'), by(f) field
			capture egen exportrank`j' = rank(revenue`j'), by(f) field

			qui corr exportrank`i' exportrank`j'
			local   A`i'_`j'  : di %3.2f int(100*r(rho))/100
					
			*adjusted correalatio
			qui reg  exportrank`i' exportrank`j' i.nprod			
			local R_full=e(r2)
			qui reg  exportrank`i'  i.nprod
			local R_minus=e(r2)
			if (`R_minus'<`R_full' &`R_minus'<1) {
					local adj_corr =sqrt((`R_full'-`R_minus')/(1-`R_minus'))
				}
			else {
			local adj_corr =0
				// Note that in general Rfull should never be < Rreduced
				// Only in the case of collinearity when exportrankj is highly correlated with some of the nprod dummies, dummies are dropped and the full model contains fewer variables. This has only happened once in our tests for MExico 2004 data, trade between SLV and USA.
			}
			
			
			
			local adj_corr =sqrt((`R_full'-`R_minus')/(1-`R_minus'))
		
			local C`i'_`j' : di %3.2f `adj_corr'
		
			// Simple and within correlation for the simulated data
			local PMC=0
			local adj_corr=0
			forvalues k=1(1)`S'{
				*simple correlation
				egen rankPMC_`k'`i' = rank(vPMC`k'_`i'), by(f) field
				capture egen rankPMC_`k'`j' = rank(vPMC`k'_`j'), by(f) field
			
				qui corr rankPMC_`k'`i' rankPMC_`k'`j'
				local PMC=r(rho)/`S'+`PMC'		
			
				* adjusted correlation
				qui reg  rankPMC_`k'`i' rankPMC_`k'`j' i.nprod
				*quietly reg  rankPMC_`k'`i' rankPMC_`k'`j' nprod
				local R_full=e(r2)
		
				qui reg   rankPMC_`k'`i'  i.nprod
				* quietly reg   rankPMC_`k'`i'  nprod
				local R_minus=e(r2)
			
				if (`R_minus'<`R_full' &`R_minus'<1){
					local temp=sqrt((`R_full'-`R_minus')/(1-`R_minus'))
				}
				else {
					local temp=0
				}
			
				local adj_corr =`temp'/`S'+`adj_corr'
				display "i=`i' j=`j' and k=`k' Rfull=`R_full'; R_minus=`R_minus'; `i'_`j'  =  `temp';  adj_corr=`adj_corr' "							
		}


			local D`i'_`j' : di %3.2f `adj_corr'
			local B`i'_`j' : di %3.2f `PMC'
		}
		else{

			local   A`i'_`j' "."
			local D`i'_`j' "."
			local B`i'_`j' "."
			local C`i'_`j' "."
		}
			display "D`i'_`j' =`D`i'_`j''"			

	}
	
}

* Write the results to LaTeX files for Tables 2 and 3, including the analysis of simple pairwise correlation and adjusted correlation.
* This section includes code to open, write to, and close LaTeX files for presenting the results in a formatted table suitable for publication.

* The LaTeX syntax is used to structure the tables, with dynamic content based on the calculated correlation coefficients.
* Instructions for constructing Tables 2 and 3 with placeholders for correlation values (`A`, `B`, `C`, `D` variables) are provided.

* Each table includes a caption, headers for countries and ranks, and footnotes explaining the methodology and data sources.

* The script concludes with closing the files after writing all necessary content for Tables 2 and 3.


local name  "Table2"


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
				   "\caption{Simple rank correlation for product sales at 10 most popular destinations. (`country' , `year') \label{SimpleRankCorr_Select1st_SP}}" _n ///
				   "\begin{tabular}{lrrrrrrrrrr}" _n ///
				   "\hline" _n ///
				   "\hline" _n ///
				   "Country &\textbf{1}&\textbf{2}&\textbf{3}&\textbf{4}&\textbf{5} &\textbf{6}&\textbf{7}&\textbf{8}&\textbf{9}&\textbf{10}\\" _n ///
				   " & \multicolumn{10}{c}{Data}\\" _n ///
				   "\cmidrule{2-11}" _n ///
				   "1 & $`A1_1'$      &            &            &              &            &              &             &            &            &                          \\  "  _n ///
				   "2 & $`A2_1'$      & $`A2_2'$   &            &              &            &              &             &            &            &                          \\  "  _n ///
				   "3 & $`A3_1'$      & $`A3_2'$   & $`A3_3'$   &              &            &              &  	         &            &            &                          \\  "  _n ///
				   "4 & $`A4_1'$      & $`A4_2'$   & $`A4_3'$   &  $`A4_4'$    &            &              &  	         &            &            &                          \\  "  _n ///
				   "5 & $`A5_1'$      & $`A5_2'$   & $`A5_3'$   &  $`A5_4'$    & $`A5_5'$   &              &             &            &            &                          \\  "  _n ///
				   "6 & $`A6_1'$      & $`A6_2'$   & $`A6_3'$   &  $`A6_4'$    & $`A6_5'$   &  $`A6_6'$    &  	         &            &            &                          \\  "  _n ///
				   "7 & $`A7_1'$      & $`A7_2'$   & $`A7_3'$   &  $`A7_4'$    & $`A7_5'$   &  $`A7_6'$    &  $`A7_7'$   &            &            &                          \\  "  _n ///
				   "8 & $`A8_1'$      & $`A8_2'$   & $`A8_3'$   &  $`A8_4'$    & $`A8_5'$   &  $`A8_6'$    &  $`A8_7'$   & $`A8_8'$   &            &                         \\  "  _n ///
				   "9 & $`A9_1'$      & $`A9_2'$   & $`A9_3'$   &  $`A9_4'$    & $`A9_5'$   &  $`A9_6'$    &  $`A9_7'$   & $`A9_8'$   & $`A9_9'$   &                          \\  "  _n ///
				   "10 & $`A10_1'$    & $`A10_2'$  & $`A10_3'$  &  $`A10_4'$   & $`A10_5'$   &  $`A10_6'$   &  $`A10_7'$  & $`A10_8'$  & $`A10_9'$  & $`A10_10'$   \\  "  _n ///
				   "\cmidrule{2-11} " _n ///
					"& \multicolumn{10}{c}{Permuted Monte-Carlo}\\ " _n ///		
				   "\cmidrule{2-11} " _n ///	
				   "1 & $`B1_1'$   &              &             &             &              &            &               &            &             &                        \\  "  _n ///
				   "2 & $`B2_1'$   & $`B2_2'$     &             &             &              &            &               &            &             &                        \\  "  _n ///
				   "3 & $`B3_1'$   & $`B3_2'$     & $`B3_3'$    &             &              &            &  	          &            &             &                        \\  "  _n ///
				   "4 & $`B4_1'$   & $`B4_2'$     & $`B4_3'$    &  $`B4_4'$   &              &            &  	          &            &             &                         \\  "  _n ///
				   "5 & $`B5_1'$   & $`B5_2'$     & $`B5_3'$    &  $`B5_4'$   & $`B5_5'$     &            &               &            &             &                         \\  "  _n ///
				   "6 & $`B6_1'$   & $`B6_2'$     & $`B6_3'$    &  $`B6_4'$   & $`B6_5'$     &  $`B6_6'$  &  	          &            &             &                         \\  "  _n ///
				   "7 & $`B7_1'$   & $`B7_2'$     & $`B7_3'$    &  $`B7_4'$   & $`B7_5'$     &  $`B7_6'$  &  $`B7_7'$     &            &             &                         \\  "  _n ///
				   "8 & $`B8_1'$   & $`B8_2'$     & $`B8_3'$    &  $`B8_4'$   & $`B8_5'$     &  $`B8_6'$  &  $`B8_7'$     & $`B8_8'$   &             &                         \\  "  _n ///
				   "9 & $`B9_1'$   & $`B9_2'$     & $`B9_3'$    &  $`B9_4'$   & $`B9_5'$     &  $`B9_6'$  &  $`B9_7'$     & $`B9_8'$   & $`B9_9'$    &                         \\  "  _n ///"\hline" _n ///
				   "10 & $`B10_1'$ & $`B10_2'$    & $`B10_3'$   &  $`B10_4'$  & $`B10_5'$    &  $`B10_6'$ &  $`B10_7'$    & $`B10_8'$  & $`B10_9'$   & $`B10_10'$ \\  "  _n ///"\hline" _n ///
				   "\hline" _n ///
				   "\end{tabular}" _n ///
				   "\begin{tablenotes}" _n ///
				   "\small" _n ///
				   "\item  \noindent  \footnotesize{The 10 most popular destinations are `destinations'. Excludes firm-destination pairs with only one product. The correlations are evaluated for destinations where at least 25 firms export.}" _n ///
				   "\end{tablenotes}" _n ///
				   "\end{threeparttable}"_n ///
				   "}" _n ///
				   "\end{table}" _n   ///
					"\end{document}" _n
file close myfile


/// Table 3 and Appendix Table 7with adjusted correlation

local name  "Table3"

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
				   "\caption{Within rank correlation for product sales at 10 most popular destinations. (`country', `year') \label{AdjRankCorr_Select1st_SP}}" _n ///
				   "\begin{tabular}{lrrrrrrrrrr}" _n ///
				   "\hline" _n ///
				   "\hline" _n ///
				   "Country &\textbf{1}&\textbf{2}&\textbf{3}&\textbf{4}&\textbf{5} &\textbf{6}&\textbf{7}&\textbf{8}&\textbf{9}&\textbf{10}\\" _n ///
				   " & \multicolumn{10}{c}{Data}\\" _n ///
				   "\cmidrule{2-11}" _n ///
					"1  & $`C1_1'$    &            &            &              &            &              &             &            &                     &                          \\  "  _n ///
					"2  & $`C2_1'$    & $`C2_2'$   &            &              &            &              &             &            &                     &                          \\  "  _n ///
					"3  & $`C3_1'$    & $`C3_2'$   & $`C3_3'$   &              &            &              &  	         &            &                     &                          \\  "  _n ///
					"4  & $`C4_1'$    & $`C4_2'$   & $`C4_3'$   &  $`C4_4'$    &            &              &  	         &            &                     &                          \\  "  _n ///
					"5  & $`C5_1'$    & $`C5_2'$   & $`C5_3'$   &  $`C5_4'$    & $`C5_5'$   &              &             &            &                     &                          \\  "  _n ///
					"6  & $`C6_1'$    & $`C6_2'$   & $`C6_3'$   &  $`C6_4'$    & $`C6_5'$   &  $`C6_6'$    &  	         &            &                     &                          \\  "  _n ///
					"7  & $`C7_1'$    & $`C7_2'$   & $`C7_3'$   &  $`C7_4'$    & $`C7_5'$   &  $`C7_6'$    &  $`C7_7'$   &            &                     &                          \\  "  _n ///
					"8  & $`C8_1'$    & $`C8_2'$   & $`C8_3'$   &  $`C8_4'$    & $`C8_5'$   &  $`C8_6'$    &  $`C8_7'$   & $`C8_8'$   &                     &                         \\  "  _n ///
					"9  & $`C9_1'$    & $`C9_2'$   & $`C9_3'$   &  $`C9_4'$    & $`C9_5'$   &  $`C9_6'$    &  $`C9_7'$   & $`C9_8'$   & $`C9_9'$            &                          \\  "  _n ///
					"10 & $`C10_1'$   & $`C10_2'$  & $`C10_3'$  &  $`C10_4'$   & $`C10_5'$  &  $`C10_6'$   &  $`C10_7'$  & $`C10_8'$  & $`C10_9'$           & $`C10_10'$   \\  "  _n ///
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
				   "\item  \noindent  \footnotesize{The 10 most popular destinations are `destinations'. Excludes firm-destination pairs with only one product. The correlations are evaluated for destinations where at least 25 firms export.}" _n ///
				   "\end{tablenotes}" _n ///
				   "\end{threeparttable}"_n ///
				   "}" _n ///
				   "\end{table}"  ///
					"\end{document}" _n
file close myfile

erase "temp.dta"