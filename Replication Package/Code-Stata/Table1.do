//This program produces table 1 in the main paper

args  Includes S country

// Load the data with product global and local rankings simulated in the data & simulated 
use rank_corr_data_PMC.dta,clear

//Group the number of destinations and the number of products per country to improve table presentation
replace nbctry =6  if nbctry>5 & nbctry<10
replace nprod_gl =6  if nprod_gl>5 & nprod_gl<10

replace nbctry =10  if nbctry>9 & nbctry<20
replace nprod_gl =10  if nprod_gl>9 & nprod_gl<20

replace nbctry =20  if nbctry>19 
replace nprod_gl =20  if nprod_gl>19 


//Evaluate simple correlation between the local and global ranks conditional on the number of products exported and the number of destinations served in the data
foreach x in  2 3 4 5 6 10 20 {

foreach y in  2 3 4 5 6 10 20{ 
	capture qui corr exportrank exportrank_gl if  nbctry==`x' & nprod_gl==`y'
	local d_corr`x'_`y' : di %3.2f int(r(rho)*100)/100
	display "d_corr`x'_`y' `d_corr`x'_`y'''"
	
}

}

//Evaluate simple correlation between the local and global ranks conditional on the number of products exported and the number of destinations served 
// in the simulated data
foreach x in  2 3 4 5 6 10 20 {

foreach y in  2 3 4 5 6 10 20{ 
	
	local av_corr=0
	forvalues i=1(1)`S'{
		capture qui corr rankPMC`i' rank_sim_gl_`i'  if nbctry==`x' & nprod_gl==`y'
		local av_corr=r(rho)/`S'+`av_corr'
		}
	local s_corr`x'_`y' : di %3.2f int(`av_corr'*100)/100
}

}

* Writing the results to a LaTeX table

local name  "Table1"

display "`country'"
display "`name'"
display "`Includes'\\`name'.tex"

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
					"\caption{Spearman rank correlation between global and local product sales. (`country')  \label{correlation1}}" _n  ///
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
					"\item  \noindent  \footnotesize{Correlation between products' global and local ranks conditional on the number of destinations and number of products a firm exports. `footnote'}" _n  ///
					"\end{tablenotes}" _n  ///
					"\end{threeparttable}" _n  ///
					"}" _n  ///
					"\end{table}"  _n ///
					"\end{document}" _n
file close myfile

