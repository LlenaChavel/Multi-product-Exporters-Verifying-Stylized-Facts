args    dirData Includes S  stataCodes country

**************************************************************************************************************************************************
do "`stataCodes'\EvaluateExcludeRank.do"  "`S'" // 

************************************************************************************************************************************************
*Count the number of observations in a group
bysort f nbctry nprod_gl: gen obs=_n
replace obs=0 if obs>1
		
bysort nbctry nprod_gl: egen total = total (obs)
		
drop if total <25

generate party_origin_interact = f +"_"+ d

foreach x in  2 3  4  5 6 10 20 {

foreach y in  2 3 4 5 6 10 20{ 
    
		*check number of observations in a group:
		count if nbctry==`x' & nprod_gl==`y'
			
		if r(N) > 0 {

			* Adjusted correlation in the data - evaluated once 
			// adj for firm X destination fixed effects
			qui areg  exportrank rankExclude if nbctry==`x' & nprod_gl==`y', absorb(party_origin_interact)
			local R_full=e(r2)

			qui areg  exportrank if nbctry==`x' & nprod_gl==`y', absorb(party_origin_interact)
			local R_minus=e(r2)

			local adj_corr =sqrt((`R_full'-`R_minus')/(1-`R_minus'))
			local d_corr`x'_`y' : di %3.2f int(`adj_corr'*100)/100
			*local d_corr`x'_`y' = `adj_corr'
				
			display "`d_corr`x'_`y''"
		
	
			* Adjusted correlation in the simulated data - evaluated S times and averaged
			*local d_corr`x'_`y'a : di %3.2f int(r(rho)*100)/100
		
			
			local av_corr=0
			forvalues i=1(1)`S'{				
				
				areg  rankPMC`i' rankExclude`i' if nbctry==`x' & nprod_gl==`y', absorb(party_origin_interact)
				local R_full=e(r2)
				
				areg  rankPMC`i' if nbctry==`x' & nprod_gl==`y', absorb(party_origin_interact)
				local R_minus=e(r2)
				
				if (`R_full'>`R_minus' & `R_minus'<1){
				    local adj_corr =sqrt((`R_full'-`R_minus')/(1-`R_minus'))
				} 
				else {
				    local adj_corr=0
				}
				
				display " x= `x' y= `y' i=`i'"
				display "`adj_corr'"
				display "`R_full'"
				display "`R_minus'"
				display "`av_corr'"
				display "1-`R_minus'"
				display "`R_full'-`R_minus'"
		
				local av_corr=`adj_corr'/`S'+`av_corr'
		    }
	    
			local s_corr`x'_`y' : di %3.2f int(`av_corr'*100)/100
			display " x = `x' y = `y'"
			display "s_corr`x'_`y' =`s_corr`x'_`y''"
			display "`av_corr'"
		
		}
		else{
			local s_corr`x'_`y' "."
			local d_corr`x'_`y' "."
		}
	}

}


************************************************************************************************************************************************
local name  "Table7-Appendix"

file open myfile using "`Includes'\\`name'.tex", write replace
file write myfile  "\documentclass{article}" _n  ///
				   "\usepackage{threeparttable}" _n  ///
				   "\usepackage{graphicx} " _n  ///
				   "\usepackage{booktabs}" _n  ///	   
					"\begin{document}" _n  ///
					"\begin{table}[h]" _n  ///
				   "\centering" _n  ///
					"\resizebox{1\width}{!}{ " _n  ///
					"\begin{threeparttable}" _n  ///
					"\caption{Within  Correlation between Products' Global  Ranks Elsewhere and Their  Local  Ranks  Adjusted for the Interaction Between  Firm and  Destination Fixed  Effects. (`country') \label{ExludeLocal-PMC-FirmXDest}}" _n  ///
					"\begin{tabular}{cllllllll} \hline\hline" _n  ///
                    "&\multicolumn{6}{c}{Number of products}\\" _n  ///
					"To number of countries       &           2  &   3            &    4          &  5         &6-9         &10-19       &20+\\\cmidrule{2-8}% " _n  ///
					"&\multicolumn{7}{c}{Data}\\	\cmidrule{2-8}%" _n  ///
					"2                           & `d_corr2_2'      & `d_corr2_3'     & `d_corr2_4'  & `d_corr2_5'  & `d_corr2_6'  & `d_corr2_10'   & `d_corr2_20' \\" _n  ///
					"3      					 & `d_corr3_2'      & `d_corr3_3'     & `d_corr3_4'  & `d_corr3_5'  & `d_corr3_6'  & `d_corr3_10'   & `d_corr3_20' \\" _n  ///
					"4                           & `d_corr4_2'      & `d_corr4_3'     & `d_corr4_4'  & `d_corr4_5'  & `d_corr4_6'  & `d_corr4_10'   & `d_corr4_20' \\" _n  ///
					"5                           & `d_corr5_2'      & `d_corr5_3'     & `d_corr5_4'  & `d_corr5_5'  & `d_corr5_6'  & `d_corr5_10'   & `d_corr5_20' \\" _n  ///
					"6                           & `d_corr6_2'      & `d_corr6_3'     & `d_corr6_4'  & `d_corr6_5'  & `d_corr6_6'  & `d_corr6_10'   & `d_corr6_20' \\" _n  ///
					"10-19                       & `d_corr10_2'     & `d_corr10_3'    & `d_corr10_4' & `d_corr10_5' & `d_corr10_6' & `d_corr10_10'  & `d_corr10_20' \\" _n ///
					"20+                         & `d_corr20_2'     & `d_corr20_3'    & `d_corr20_4' & `d_corr20_5' & `d_corr20_6' & `d_corr20_10'  & `d_corr20_20' \\" _n ///
					"\cmidrule{2-8}%" _n  ///
					"& \multicolumn{7}{c}{Permuted Monte Carlo}\\	\cmidrule{2-8}%" _n  ///
					"2      					& `s_corr2_2'      & `s_corr2_3'     & `s_corr2_4'  & `s_corr2_5'  & `s_corr2_6'  & `s_corr2_10'   & `s_corr2_20' \\" _n  ///
					"3      					& `s_corr3_2'      & `s_corr3_3'     & `s_corr3_4'  & `s_corr3_5'  & `s_corr3_6'  & `s_corr3_10'   & `s_corr3_20' \\" _n  ///
					"4      					& `s_corr4_2'      & `s_corr4_3'     & `s_corr4_4'  & `s_corr4_5'  & `s_corr4_6'  & `s_corr4_10'   & `s_corr4_20' \\" _n  ///
					"5      					& `s_corr5_2'      & `s_corr5_3'     & `s_corr5_4'  & `s_corr5_5'  & `s_corr5_6'  & `s_corr5_10'   & `s_corr5_20' \\" _n  ///
					"6     						& `s_corr6_2'      & `s_corr6_3'     & `s_corr6_4'  & `s_corr6_5'  & `s_corr6_6'  & `s_corr6_10'   & `s_corr6_20' \\" _n  ///
					"10-19  				    & `s_corr10_2'     & `s_corr10_3'    & `s_corr10_4' & `s_corr10_5' & `s_corr10_6' & `s_corr10_10'  & `s_corr10_20' \\" _n ///
					"20+    					& `s_corr20_2'     & `s_corr20_3'    & `s_corr20_4' & `s_corr20_5' & `s_corr20_6' & `s_corr20_10'  & `s_corr20_20' \\" _n ///
					"\hline\hline" _n  ///
					"\end{tabular}" _n  ///
					"\begin{tablenotes}" _n  ///
					"\small" _n  ///
				    "\item  \noindent  \footnotesize{\emph{Note:} Correlation is reported conditional on both the overall number of products a firm exports and the number of destinations reached. Correlation is evaluated for groups that contain at least 25 firms. }" _n  ///
					"\end{tablenotes}" _n  ///
					"\end{threeparttable}" _n  ///
					"}" _n  ///
					"\end{table}"  _n ///
					"\end{document}" _n
file close myfile

/*
erase "temp.dta"
erase "data_by_country.dta"
erase "exporters_at_dest.dta"
erase "PMC_only_world.dta"
erase "rank_corr_data_PMC.dta"
