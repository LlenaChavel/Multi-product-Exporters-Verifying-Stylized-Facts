
//This program reproduces Tables1 in the Appendix
* Arguments:
* - dirData: Directory for data files.
* - Includes: Directory for saving output files.
args    dirData Includes

// Load the dataset with exporter data
use rank_corr_data_PMC,clear
//keep exporters to the US
keep if d=="502"

// Retain only the relevant variables for this part of the analysis.
keep f hs v nprod exportrank

// Generate variables to identify the best and least selling products based on their values.
gen best_selling =v
gen least_selling =v

// Initialize a variable to differentiate between scopes of export activity.
gen Scope =1 

// Collapse the dataset to sum up sales, and find the minimum and maximum selling values by firm.
// This aggregation provides a concise summary for further analysis.
collapse (sum)v Scope (min)least_selling (max) best_selling ,by(f)

// Convert sales values from their original scale to thousands for easier interpretation.
replace v  = v/1000
replace least_selling= least_selling/1000
replace best_selling= best_selling/1000

// Categorize firms into quartiles based on their scope for a detailed analysis.
xtile PC=Scope, nq(4)

// Count the number of observations in each scope category to understand distribution.
bysort PC: egen obs =count(PC)

// Collapse the dataset to calculate mean sales and number of observations by product category (PC).
collapse (mean)v least_selling best_selling (mean)obs,by(PC)

// Calculate the total number of observations across all categories and normalize observations to percentages
order PC
local obs_total=obs[1]+obs[2]+obs[3]+obs[4]
replace obs=round(100*obs/`obs_total')

// Round sales values for presentation clarity in the output.
replace v=round(v)
replace best_selling =round(best_selling)
replace least_selling =round(least_selling)

// Label variables for clarity in the output table.
label var  obs "Percent" 
label var  v "Total Firm Sales"
label var  best_selling "Top ranked product"
label var  least_selling "Bottom ranked product"

// Convert the dataset to a matrix format for easy export to LaTeX.
mkmat obs  v  best_selling  least_selling, matrix(anys)
matrix transpose =anys'

// Rename matrix rows and columns to match table specifications.
matrix colnames transpose = "1" "2" "3-4" "5+"
matrix rownames transpose = "Share "  "Mean Total Firm Sales"  "Mean Top ranked product"  "Mean Bottom ranked product" 

// Display the matrix to verify data before export.
matrix list transpose

forvalues i=1(1)4{
	forvalues j=1(1)5{
		local T_`i'_`j'=el(transpose,`i',`j')
	}
}

* Open a file to write the LaTeX code for the summary statistics table.
* This table will summarize the export activities exporters to the US.

file open myfile using "`Includes'\\Table1-Appendix.tex", write replace
file write myfile  "\documentclass{article}" _n  ///
				   "\usepackage{threeparttable}" _n  ///
				   "\usepackage{graphicx} " _n  ///
				   "\usepackage{booktabs}" _n  ///
				   "\begin{document}" _n  ///
				   "\begin{table}[h]" _n  ///
				   "\centering" _n  ///
					"\resizebox{1\width}{!}{ " _n  ///
					"\begin{threeparttable}" _n  ///
					"\caption{Summary Statistics for the Chinese Exporters to the US}" _n  ///
					"\begin{tabular}{lcccc} \hline\hline" _n  ///
                    "Scope                       &     1        &   2         &    3-4   &  5+      \\" _n  ///
					"\hline" _n  ///
					"Exporter Share with Scope   & `T_1_1'      & `T_1_2'     & `T_1_3'  &  `T_1_4' \\" _n  ///
					"Mean Total Firm sales       & `T_2_1'      & `T_2_2'     & `T_2_3'  & `T_2_4'  \\" _n  ///
					"Mean Top Ranked Product	 & `T_3_1'      & `T_3_2'     & `T_3_3'  &  `T_3_4' \\" _n  ///
					"Mean Bottom Ranked Product  & `T_4_1'      & `T_4_2'     & `T_4_3'  & `T_4_4'  \\" _n  ///
					"\hline\hline" _n  ///
					"\end{tabular}" _n  ///
					"\begin{tablenotes}" _n  ///
					"\small" _n  ///
					"\item  \noindent  \footnotesize{The table splits the sample of exporters from China to the US according to the number of products that they exported in 2003  into exporters with 1,2,3-4, and 5 or more products. For each group it reports the share of exporters, mean total exporter sales and mean sales of the best and least-selling products. Sales are in thousands of USD.}" _n  ///
					"\end{tablenotes}" _n  ///
					"\end{threeparttable}" _n  ///
					"}" _n  ///
					"\end{table}"  _n ///
					"\end{document}" _n
file close myfile

