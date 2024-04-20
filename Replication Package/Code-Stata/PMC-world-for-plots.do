// This script transforms the data on local ranks to a long format and calculates the mean sales at each rank.
// These calculations are needed for constructing Figures 1 and 2.
// The script expects the number of permutations 'S' as an argument.

args S

// The loop below processes 'S' permutations, creating a long-format dataset that includes a new variable 'permutation'
// indicating the permutation iteration. This format is usefull for subsequent analysis and visualization.
// Iterates over each permutation (from 1 to 'S'), using the rank and sales data from the 'rank_corr_data_PMC' dataset.
// It keeps only the relevant variables for the current permutation, renames them for consistency, and saves each iteration's data in a temporary file.

// For each permutation, a variable 'permutation' is generated to track the permutation number. This aids in distinguishing between data from different permutations.

forvalues i=1(1)`S'{
    use  rank_corr_data_PMC,clear
    keep f y d rankPMC`i' vPMC`i' nprod
	
	rename rankPMC`i' rank
	rename vPMC`i' v
	
	sort f y d rank
	gen permutation =`i'



	save temp`i', replace
	
	}
	
// // Starting with the data from the first permutation, the script appends data from subsequent permutations to create a comprehensive dataset.
// This step consolidates the separate permutation datasets into a single long-format dataset for analysis.

use temp1, clear 
forvalues i=2(1)`S'{
   append using temp`i'
}

gen lvalue=log(v)

// Saves the final, combined dataset as 'PMC_only_world.dta'.
// The dataset includes variables for party ID ('f'), origin ID ('d'), year ('y'), value ('v'), number of products ('nprod'), rank ('rank'), and permutation number.
// Note: This dataset only contains permuted variables; the original, unpermuted data is not included.
save PMC_only_world.dta, replace 


// List files starting with 'temp' and ending with '.dta' and store their names
local files : dir . files "temp*.dta"

// Loop through the list of files and delete each one
foreach file of local files {
    erase "`file'"
}
